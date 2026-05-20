--離世召人形
-- 效果：
-- ①：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡特殊召唤。
-- ②：自己·对方的战斗阶段开始时发动。自己卡组的数量比对方多的场合，这张卡的攻击力直到回合结束时上升那个相差数量×300。
-- ③：这张卡被送去墓地的回合的结束阶段发动。这张卡回到卡组最上面。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含抽卡时特召、战斗阶段开始时增攻、送墓回合结束时回卡组最上方的效果。
function s.initial_effect(c)
	-- ①：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DRAW)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的战斗阶段开始时发动。自己卡组的数量比对方多的场合，这张卡的攻击力直到回合结束时上升那个相差数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的回合
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的回合的结束阶段发动。这张卡回到卡组最上面。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.tdcon)
	e4:SetTarget(s.tdtg)
	e4:SetOperation(s.tdop)
	c:RegisterEffect(e4)
end
-- 效果①的Cost函数，确认这张卡在手卡中且未给对方观看（非公开状态）。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 效果①的Target函数，确认自身可以特殊召唤且怪兽区域有空位。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查发动玩家的怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息，表示该效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的Operation函数，将这张卡在自身场上表侧表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关联，则将其表侧表示特殊召唤到发动玩家的场上。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 效果②的Operation函数，计算双方卡组数量差，并使此卡的攻击力上升相差数量×300。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 计算自己卡组数量与对方卡组数量的差值。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)-Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	if c:IsRelateToEffect(e) and c:IsFaceup() and ct>0 then
		-- 这张卡的攻击力直到回合结束时上升那个相差数量×300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(ct*300)
		c:RegisterEffect(e1)
	end
end
-- 效果③的辅助注册函数，在此卡被送去墓地时，为其注册一个持续到回合结束的标记。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果③的发动条件，检查此卡在本回合内是否被送去过墓地（是否存在对应的标记）。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 效果③的Target函数，设置将自身送回卡组的操作信息。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁信息，表示该效果包含将自身送回卡组的操作。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 效果③的Operation函数，将此卡送回卡组最上面。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关联，则通过效果将其送回持有者卡组的最上面。
	if c:IsRelateToEffect(e) then Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT) end
end
