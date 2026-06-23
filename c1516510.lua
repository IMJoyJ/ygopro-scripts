--ルーンアイズ・ペンデュラム・ドラゴン
-- 效果：
-- 「异色眼灵摆龙」＋魔法师族怪兽
-- ①：这张卡得到「异色眼灵摆龙」以外的作为融合素材的怪兽的原本等级的以下效果。
-- ●4星以下：这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ●5星以上：这张卡在同1次的战斗阶段中最多3次可以向怪兽攻击。
-- ②：场上的灵摆召唤的怪兽作为素材让这张卡融合召唤成功的回合，这张卡不受对方的效果影响。
function c1516510.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为16178681的怪兽和1个魔法师族怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,16178681,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),1,true,true)
	-- ①：这张卡得到「异色眼灵摆龙」以外的作为融合素材的怪兽的原本等级的以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c1516510.condition)
	e1:SetOperation(c1516510.operation)
	c:RegisterEffect(e1)
	-- ②：场上的灵摆召唤的怪兽作为素材让这张卡融合召唤成功的回合，这张卡不受对方的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c1516510.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 判断此卡是否为融合召唤
function c1516510.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 根据融合素材等级设置攻击次数和免疫效果
function c1516510.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local flag=e:GetLabel()
	if bit.band(flag,0x3)~=0 then
		-- ●4星以下：这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		if bit.band(flag,0x1)~=0 then
			e1:SetDescription(aux.Stringid(1516510,0))  --"最多2次可以向怪兽攻击"
			e1:SetValue(1)
		else
			e1:SetDescription(aux.Stringid(1516510,1))  --"最多3次可以向怪兽攻击"
			e1:SetValue(2)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	if bit.band(flag,0x4)~=0 then
		-- ●5星以上：这张卡在同1次的战斗阶段中最多3次可以向怪兽攻击。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_IMMUNE_EFFECT)
		e4:SetValue(c1516510.efilter)
		e4:SetOwnerPlayer(tp)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e4)
	end
end
-- 效果免疫对方效果
function c1516510.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
-- 判断是否为异色眼灵摆龙或可替代融合素材的怪兽
function c1516510.lvfilter(c,fc)
	return c:IsCode(16178681) or c:CheckFusionSubstitute(fc)
end
-- 判断是否为灵摆召唤的怪兽
function c1516510.imfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 检查融合素材并设置效果标记
function c1516510.valcheck(e,c)
	local g=c:GetMaterial()
	local flag=0
	if g:GetCount()==2 then
		local lv=0
		local lg1=g:Filter(c1516510.lvfilter,nil,c)
		local lg2=g:Filter(Card.IsRace,nil,RACE_SPELLCASTER)
		if lg1:GetCount()==2 then
			lv=lg2:GetFirst():GetOriginalLevel()
			local lc=lg2:GetNext()
			if lc then lv=math.max(lv,lc:GetOriginalLevel()) end
		else
			local lc=g:GetFirst()
			if lc==lg1:GetFirst() then lc=g:GetNext() end
			lv=lc:GetOriginalLevel()
		end
		if lv>4 then
			flag=0x2
		elseif lv>0 then
			flag=0x1
		end
	end
	if g:IsExists(c1516510.imfilter,1,nil) then
		flag=flag+0x4
	end
	e:GetLabelObject():SetLabel(flag)
end
