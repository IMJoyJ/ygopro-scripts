--灰塵王 アッシュ・ガッシュ
-- 效果：
-- 这张卡给与对方基本分战斗伤害时，这张卡的等级上升1星（等级最多12星）。
function c19012345.initial_effect(c)
	-- 这张卡给与对方基本分战斗伤害时，这张卡的等级上升1星（等级最多12星）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19012345,0))  --"等级上升"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c19012345.condition)
	e1:SetOperation(c19012345.operation)
	c:RegisterEffect(e1)
end
-- 诱发条件：对方玩家受到战斗伤害（ep~=tp），且这张卡的当前等级在11星以下（含11星），以保证上升后最多不超过12星。
function c19012345.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and e:GetHandler():IsLevelBelow(11)
end
-- 处理时：获取效果所属的这张卡；若这张卡已不与该效果关联或因里侧表示等无法处理则直接结束；否则给这张卡注册一个永续效果，令其等级上升1星，并在离场、回手牌、回卡组、除外、送墓、翻转重置或效果被无效时重置该等级提升效果。
function c19012345.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 这张卡的等级上升1星（等级最多12星）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
