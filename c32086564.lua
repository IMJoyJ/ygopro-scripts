--エクシーズ・トライバル
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，持有超量素材2个以上的超量怪兽不会被效果破坏。
-- ②：这张卡在魔法与陷阱区域存在，自己的超量怪兽和对方怪兽进行战斗的伤害计算后发动。那只对方怪兽破坏。这个效果在那只自己怪兽持有超量素材2个以上的场合才能发动和处理。
function c32086564.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，持有超量素材2个以上的超量怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c32086564.target)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：这张卡在魔法与陷阱区域存在，自己的超量怪兽和对方怪兽进行战斗的伤害计算后发动。那只对方怪兽破坏。这个效果在那只自己怪兽持有超量素材2个以上的场合才能发动和处理。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32086564,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(c32086564.destg)
	e3:SetOperation(c32086564.desop)
	c:RegisterEffect(e3)
end
-- 永续效果的过滤条件：只有持有超量素材2个以上的超量怪兽才适用此免疫效果破坏的效果。
function c32086564.target(e,c)
	return c:GetOverlayCount()>=2
end
-- ②的发动条件和效果对象判定：在伤害计算后检查自己的超量怪兽是否与对方怪兽战斗，且自己怪兽持有超量素材2个以上，满足则准备破坏对方怪兽。
function c32086564.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得tp玩家当前参与战斗的怪兽：a为自己怪兽，d为对方怪兽；若无战斗怪兽则均为nil。
	local a,d=Duel.GetBattleMonster(tp)
	if chk==0 then return a and d and a:GetOverlayCount()>=2 end
	-- 将本次连锁处理信息登记为“破坏1只怪兽”，对象为对方战斗怪兽，以便其他卡能够对应此破坏效果进行发动。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,d,1,0,0)
end
-- ②的实际处理：若战斗双方怪兽仍与本次战斗关联，且自己怪兽持有超量素材2个以上，则将对方怪兽破坏。
function c32086564.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次取得tp玩家当前参与战斗的怪兽，用于效果处理时确认对象仍然存在。
	local a,d=Duel.GetBattleMonster(tp)
	if a and d and a:IsRelateToBattle() and d:IsRelateToBattle() and a:GetOverlayCount()>=2 then
		-- 以效果原因将对方战斗怪兽破坏。
		Duel.Destroy(d,REASON_EFFECT)
	end
end
