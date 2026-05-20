--アーマーブラスト
-- 效果：
-- 选择自己场上1张名字带有「甲虫装机」的卡和对方场上表侧表示存在的2张卡发动。选择的卡破坏。
function c79155167.initial_effect(c)
	-- 选择自己场上1张名字带有「甲虫装机」的卡和对方场上表侧表示存在的2张卡发动。选择的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c79155167.target)
	e1:SetOperation(c79155167.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的「甲虫装机」卡片的条件函数
function c79155167.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x56)
end
-- 过滤对方场上表侧表示卡片的条件函数
function c79155167.filter2(c)
	return c:IsFaceup()
end
-- 效果发动时的对象选择与合法性检测
function c79155167.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少1张表侧表示的「甲虫装机」卡片
	if chk==0 then return Duel.IsExistingTarget(c79155167.filter1,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查对方场上是否存在至少2张表侧表示的卡片
		and Duel.IsExistingTarget(c79155167.filter2,tp,0,LOCATION_ONFIELD,2,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张表侧表示的「甲虫装机」卡片作为效果对象
	local g1=Duel.SelectTarget(tp,c79155167.filter1,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上2张表侧表示的卡片作为效果对象
	local g2=Duel.SelectTarget(tp,c79155167.filter2,tp,0,LOCATION_ONFIELD,2,2,nil)
	g1:Merge(g2)
	-- 设置效果处理信息为破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
end
-- 过滤出在效果处理时仍表侧表示存在且与该效果有关联的对象卡片
function c79155167.tgfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- 效果处理函数，获取并破坏选中的对象卡片
function c79155167.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(c79155167.tgfilter,nil,e)
	if tg:GetCount()>0 then
		-- 破坏所有符合条件的对象卡片
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
