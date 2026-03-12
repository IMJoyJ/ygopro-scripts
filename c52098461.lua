--ラス・オブ・ネオス
-- 效果：
-- ①：以自己的怪兽区域1只「元素英雄 新宇侠」为对象才能发动。那只「元素英雄 新宇侠」回到持有者卡组，场上的卡全部破坏。
function c52098461.initial_effect(c)
	-- 记录该卡具有「元素英雄 新宇侠」的卡片密码，用于后续效果判断
	aux.AddCodeList(c,89943723)
	-- 为该卡添加「元素英雄」系列编码，用于系列判定
	aux.AddSetNameMonsterList(c,0x3008)
	-- 以自己的怪兽区域1只「元素英雄 新宇侠」为对象才能发动。那只「元素英雄 新宇侠」回到持有者卡组，场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c52098461.target)
	e1:SetOperation(c52098461.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示的「元素英雄 新宇侠」且能送入卡组
function c52098461.filter(c)
	return c:IsFaceup() and c:IsCode(89943723) and c:IsAbleToDeck()
end
-- 处理效果的发动条件和目标选择逻辑
function c52098461.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c52098461.filter(chkc) end
	-- 检查自己场上是否存在至少1只符合条件的「元素英雄 新宇侠」
	if chk==0 then return Duel.IsExistingTarget(c52098461.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查场上的卡是否至少有2张（用于破坏效果）
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,e:GetHandler()) end
	-- 向玩家提示选择要送入卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择目标怪兽，即自己场上的1只「元素英雄 新宇侠」
	local g=Duel.SelectTarget(tp,c52098461.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 获取场上所有卡的集合
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	dg:RemoveCard(g:GetFirst())
	-- 设置操作信息：将选中的怪兽送入卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置操作信息：将场上的其他卡全部破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 处理效果的发动和执行逻辑
function c52098461.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c52098461.filter(tc)
		-- 确认目标怪兽已回到卡组并成功送入卡组
		and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK) then
		-- 获取场上所有卡（除该卡外）的集合
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
		-- 将场上所有卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
