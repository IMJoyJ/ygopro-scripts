--魔轟神獣ユニコール
-- 效果：
-- 「魔轰神」调整＋调整以外的怪兽1只以上
-- ①：只要这张卡在怪兽区域存在并是双方手卡相同数量，对方发动的魔法·陷阱·怪兽的效果无效化并破坏。
function c44155002.initial_effect(c)
	-- 添加同调召唤手续，要求1只满足「魔轰神」属性的调整，以及1只以上调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x35),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在并是双方手卡相同数量，对方发动的魔法·陷阱·怪兽的效果无效化并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetOperation(c44155002.disop)
	c:RegisterEffect(e1)
end
-- 定义连锁处理时触发的效果操作函数
function c44155002.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为己方发动或双方手卡数量不同，若满足则不执行后续操作
	if ep==tp or Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)~=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND) then return end
	local rc=re:GetHandler()
	-- 使当前连锁效果无效并检查目标卡片是否与该效果相关联
	if Duel.NegateEffect(ev,true) and rc:IsRelateToEffect(re) then
		-- 将目标卡片因效果破坏
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
