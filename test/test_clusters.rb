require_relative 'helpers'

class ClustersTest < IWNGTest
  def test_create
    count_before = client.clusters_list.count
    id = client.clusters_create({name: 'test_name'})
    count_after = client.clusters_list.count

    assert_true id.length == 24
    assert_equal 1, count_after - count_before
  end

  def test_get
    name = "test#{Time.now.to_i}"
    id = client.clusters_create({name: name})

    cluster = client.clusters_get(id)

    assert_equal id, cluster.id
    assert_equal name, cluster.name
  end

  def test_update
    id = client.clusters_create({name: 'test_name'})

    name = "test#{Time.now.to_i}"
    client.clusters_update(id, {name: name})
    cluster = client.clusters_get(id)

    assert_equal name, cluster.name
  end

  def test_delete
    id = client.clusters_create({name: 'test'})
    count_before = client.clusters_list.count

    client.clusters_delete(id)
    count_after = client.clusters_list.count

    assert_equal -1, count_after - count_before
  end    
end
