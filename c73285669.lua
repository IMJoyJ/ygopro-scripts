--剣闘獣エセダリ
-- 效果：
-- 名字带有「剑斗兽」的怪兽×2
-- 让自己场上的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
function c73285669.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为2只名字带有「剑斗兽」的怪兽
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1019),2,true)
	-- 添加接触融合召唤手续，通过将自己怪兽区上记的素材卡回到卡组来从额外卡组特殊召唤
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_MZONE,0,aux.ContactFusionSendToDeck(c))
	-- 让自己场上的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c73285669.splimit)
	c:RegisterEffect(e1)
end
-- 限制该卡在额外卡组时不能通过接触融合以外的其他方式特殊召唤
function c73285669.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
