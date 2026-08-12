--Emトラピーズ・ハイ・マジシャン
-- 效果：
-- 魔法师族5星怪兽×2
-- ①：持有超量素材的这张卡不会被战斗·效果破坏。
-- ②：只要这张卡在怪兽区域存在，自己受到的效果伤害由对方代受（这个效果在1回合可以适用最多有这张卡的超量素材数量的次数）。
-- ③：这张卡有「娱乐法师 秋千魔术家」在作为超量素材的场合，得到以下效果。
-- ●把这张卡1个超量素材取除才能发动。这个回合，这张卡在同1次的战斗阶段中可以作3次攻击。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含超量召唤手续、抗性、伤害反射和追加攻击效果。
function s.initial_effect(c)
	-- 将「娱乐法师 秋千魔术家」（卡号17016362）加入卡片记述的卡名列表中。
	aux.AddCodeList(c,17016362)
	-- 添加超量召唤手续：魔法师族5星怪兽×2。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),5,2)
	c:EnableReviveLimit()
	-- ①：持有超量素材的这张卡不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.intcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己受到的效果伤害由对方代受（这个效果在1回合可以适用最多有这张卡的超量素材数量的次数）。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_REFLECT_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetValue(s.val)
	c:RegisterEffect(e3)
	-- ③：这张卡有「娱乐法师 秋千魔术家」在作为超量素材的场合，得到以下效果。●把这张卡1个超量素材取除才能发动。这个回合，这张卡在同1次的战斗阶段中可以作3次攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))  --"3次攻击"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.tacon)
	e4:SetCost(s.tacost)
	e4:SetTarget(s.tatg)
	e4:SetOperation(s.taop)
	c:RegisterEffect(e4)
end
-- 破坏抗性效果的适用条件：这张卡持有超量素材。
function s.intcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()~=0
end
-- 追加攻击效果的发动条件：可以进入战斗阶段，且超量素材中有「娱乐法师 秋千魔术家」。
function s.tacon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家能否进入战斗阶段，且超量素材中是否存在卡号为17016362的卡。
	return Duel.IsAbleToEnterBP() and e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,17016362)
end
-- 追加攻击效果的代价：取除这张卡的1个超量素材。
function s.tacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 追加攻击效果的靶向/发动准备：检查自身是否尚未获得追加攻击效果。
function s.tatg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK)==0 end
end
-- 追加攻击效果的落实力度：给自身添加在同一次战斗阶段中可以作3次攻击的效果。
function s.taop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 这个回合，这张卡在同1次的战斗阶段中可以作3次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(2)
	c:RegisterEffect(e1)
end
-- 伤害反射效果的适用函数：判断是否为效果伤害，且本回合已适用的次数小于超量素材数量，适用时注册一次性标记。
function s.val(e,re,ev,r,rp,rc)
	local ct=e:GetHandler():GetFlagEffect(id)
	if bit.band(r,REASON_EFFECT)~=0 and e:GetHandler():GetOverlayCount()>ct then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		return true
	end
	return false
end
