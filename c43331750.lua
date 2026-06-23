--融合複製
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己或对方的墓地1张「融合」通常·速攻魔法卡为对象才能发动。那张魔法卡除外。那之后，那张魔法卡发动时的效果适用。
local s,id,o=GetID()
-- 初始化卡片效果，注册魔法卡发动效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己或对方的墓地1张「融合」通常·速攻魔法卡为对象才能发动。那张魔法卡除外。那之后，那张魔法卡发动时的效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己或对方墓地中满足条件的「融合」通常·速攻魔法卡，且能够除外且能正常复制适用其效果的过滤条件
function s.filter(c)
	return (c:GetType()==TYPE_SPELL or c:IsType(TYPE_QUICKPLAY)) and c:IsSetCard(0x46) and c:IsAbleToRemove()
		and c:CheckActivateEffect(true,true,false)~=nil
end
-- 效果发动的目标检查与选择函数，执行复制墓地魔法卡效果的相关初始化与属性设置
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc) end
	-- 检查双方墓地是否存在符合除外及效果适用条件的「融合」通常·速攻魔法卡
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择双方墓地中1张符合条件的魔法卡作为对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	local tc=g:GetFirst()
	-- 清除当前的连锁对象，避免后续的复制效果被视为以原卡片为对象
	Duel.ClearTargetCard()
	tc:CreateEffectRelation(e)
	e:SetLabelObject(tc)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(true,true,true)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	-- 清除当前连锁的操作信息，以确保复制的卡片效果不会错误地受到连锁响应的检测影响
	Duel.ClearOperationInfo(0)
	-- 设置将选中的魔法卡除外的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理的激活函数，执行将目标魔法卡除外并适用其发动效果的处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local fc=e:GetLabelObject()
	-- 检查目标卡片是否仍与连锁相关，并执行将其除外的操作，判断是否除外成功
	if fc and fc:IsRelateToChain() and Duel.Remove(fc,POS_FACEUP,REASON_EFFECT)>0
		and fc:IsLocation(LOCATION_REMOVED) then
		local fe=fc:CheckActivateEffect(true,true,true)
		if fe then
			local op=fe:GetOperation()
			if op then
				-- 中断当前效果处理，使后续适用的魔法卡效果与除外处理不同时进行
				Duel.BreakEffect()
				op(e,tp,eg,ep,ev,re,r,rp)
			end
		end
	end
end
