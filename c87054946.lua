--焔凰神－ネフティス
-- 效果：
-- 包含仪式怪兽的怪兽2只以上
-- ①：这张卡得到作为这张卡的连接素材的仪式怪兽数量的以下效果。
-- ●1只以上：这张卡不会被战斗破坏。
-- ●2只以上：这张卡的攻击力上升1200，不会被效果破坏。
-- ●3只：这张卡的攻击力上升1200，不会成为效果的对象。
-- ②：只要这张卡在额外怪兽区域存在，对方不能选择主要怪兽区域的「奈芙提斯」怪兽作为攻击对象。
function c87054946.initial_effect(c)
	-- 设置连接召唤手续，需要至少2只怪兽作为素材，且必须包含仪式怪兽。
	aux.AddLinkProcedure(c,nil,2,nil,c87054946.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡得到作为这张卡的连接素材的仪式怪兽数量的以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c87054946.regcon)
	e1:SetOperation(c87054946.regop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在额外怪兽区域存在，对方不能选择主要怪兽区域的「奈芙提斯」怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c87054946.atcon)
	e2:SetValue(c87054946.atlimit)
	c:RegisterEffect(e2)
end
-- 检查连接素材中是否存在至少1只仪式怪兽。
function c87054946.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_RITUAL)
end
-- 检查这张卡是否是通过连接召唤特殊召唤成功的。
function c87054946.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 统计作为连接素材的仪式怪兽数量，并根据数量赋予这张卡对应的永续效果。
function c87054946.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetMaterial():FilterCount(Card.IsLinkType,nil,TYPE_RITUAL)
	if ct>=1 then
		-- ●1只以上：这张卡不会被战斗破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(87054946,0))  --"1只以上怪兽为素材"
	end
	if ct>=2 then
		-- ●2只以上：这张卡的攻击力上升1200
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(1200)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- ●2只以上：不会被效果破坏。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(87054946,1))  --"2只以上怪兽为素材"
	end
	if ct==3 then
		-- ●3只：这张卡的攻击力上升1200
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e4:SetCode(EFFECT_UPDATE_ATTACK)
		e4:SetRange(LOCATION_MZONE)
		e4:SetValue(1200)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e4)
		-- ●3只：不会成为效果的对象。
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e5:SetRange(LOCATION_MZONE)
		e5:SetValue(1)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e5)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(87054946,2))  --"3只怪兽为素材"
	end
end
-- 检查这张卡是否在额外怪兽区域。
function c87054946.atcon(e)
	return e:GetHandler():GetSequence()>4
end
-- 过滤出主要怪兽区域表侧表示的「奈芙提斯」怪兽，使其不能被选择为攻击对象。
function c87054946.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x11f) and c:GetSequence()<5
end
