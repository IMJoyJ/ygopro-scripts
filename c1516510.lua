--ルーンアイズ・ペンデュラム・ドラゴン
-- 效果：
-- 「异色眼灵摆龙」＋魔法师族怪兽
-- ①：这张卡得到「异色眼灵摆龙」以外的作为融合素材的怪兽的原本等级的以下效果。
-- ●4星以下：这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ●5星以上：这张卡在同1次的战斗阶段中最多3次可以向怪兽攻击。
-- ②：场上的灵摆召唤的怪兽作为素材让这张卡融合召唤成功的回合，这张卡不受对方的效果影响。
function c1516510.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以1只“异色眼灵摆龙”和1只魔法师族怪兽为融合素材，允许融合素材代用品。
	aux.AddFusionProcCodeFun(c,16178681,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),1,true,true)
	-- ①：这张卡得到「异色眼灵摆龙」以外的作为融合素材的怪兽的原本等级的以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c1516510.condition)
	e1:SetOperation(c1516510.operation)
	c:RegisterEffect(e1)
	-- 「异色眼灵摆龙」＋魔法师族怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c1516510.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 判定这张卡是否是以融合召唤方式成功特殊召唤，仅融合召唤成功时触发后续处理。
function c1516510.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 融合召唤成功时，根据素材检查得到的标记flag：若有4星以下素材则赋予同一战斗阶段最多2次攻击；若有5星以上素材则赋予最多3次攻击；若有灵摆召唤的素材怪兽则本回合免疫对方效果。
function c1516510.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local flag=e:GetLabel()
	if bit.band(flag,0x3)~=0 then
		-- ●4星以下：这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。●5星以上：这张卡在同1次的战斗阶段中最多3次可以向怪兽攻击。
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
		-- ②：场上的灵摆召唤的怪兽作为素材让这张卡融合召唤成功的回合，这张卡不受对方的效果影响。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_IMMUNE_EFFECT)
		e4:SetValue(c1516510.efilter)
		e4:SetOwnerPlayer(tp)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e4)
	end
end
-- 判断效果来源是否来自对方：免疫效果的持有者（此卡的控制者）与效果发动玩家不同时，该效果为对方效果，从而被免疫。
function c1516510.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
-- 判断素材是否为“异色眼灵摆龙”（卡号16178681），或是可作为融合素材代用品代替其的怪兽，用于在融合素材中识别“异色眼灵摆龙”。
function c1516510.lvfilter(c,fc)
	return c:IsCode(16178681) or c:CheckFusionSubstitute(fc)
end
-- 判断素材是否位于怪兽区域且是以灵摆召唤方式特殊召唤的怪兽，用于判定②的“场上的灵摆召唤的怪兽作为素材”。
function c1516510.imfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 计算素材标记：若素材数为2，优先按非“异色眼灵摆龙/代用”的素材的原本等级设置flag（1~4星为0x1，5星以上为0x2）；若素材中存在灵摆召唤的怪兽，则flag加上0x4，最后将flag保存到e1的Label中供后续处理。
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
