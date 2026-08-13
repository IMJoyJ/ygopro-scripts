--ゴーティスの兆イグジープ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：鱼族怪兽被除外的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被除外的下个回合的准备阶段，以自己的墓地·除外状态的1张「魊影」陷阱卡为对象才能发动。那张卡在自己场上盖放。
local s,id,o=GetID()
-- 定义初始效果注册函数：创建并注册效果①（手牌发动的诱发效果，鱼族怪兽被除外时特殊召唤自身）和效果②（除外区发动的诱发效果，下个准备阶段盖放墓地/除外状态的「魊影」陷阱卡）。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：鱼族怪兽被除外的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_REMOVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的下个回合的准备阶段，以自己的墓地·除外状态的1张「魊影」陷阱卡为对象才能发动。那张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 筛选条件：被除外的怪兽是表侧表示且种族为鱼族。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH)
end
-- 效果①的发动条件：本连锁被除外的怪兽中存在至少1只满足s.cfilter的表侧鱼族怪兽，即鱼族怪兽被除外的场合。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
-- 效果①的目标检查：取得效果持有者（这张卡），若自己主要怪兽区有空位且这张卡能被特殊召唤则允许发动，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动合法性检测（chk==0）时，确认自己主要怪兽区有空位且这张卡当前可以被特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息为特殊召唤这张卡（1张），使相关效果（如召唤限制、星尘龙等）能正确检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的处理：若这张卡仍与效果关联，则将其特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②的发动条件：取得效果持有者，当前回合数比这张卡被除外的回合数多1，即处于被除外的下个回合（发动时机由准备阶段事件限定）。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 具体判断：当前回合数 - 这张卡被除外的回合数 == 1，确保发动时机在被除外的下个回合。
	return Duel.GetTurnCount()-c:GetTurnID()==1
end
-- 对象筛选：选择自己墓地·除外状态的卡，要求为表侧表示（墓地中的卡视为满足表侧条件）、陷阱卡、属于「魊影」字段、且可以盖放到魔法与陷阱区。
function s.setfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_TRAP) and c:IsSetCard(0x18a) and c:IsSSetable()
end
-- 效果②的取对象处理：确认对象必须是自己墓地·除外状态且满足s.setfilter的卡；合法性检测时判断是否存在这样的对象；然后选择1张作为对象，若对象在墓地则设置离开墓地的操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.setfilter(chkc) end
	-- 在合法性检测（chk==0）时，确认墓地·除外状态存在至少1张满足条件的「魊影」陷阱卡可选。
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 向操作玩家显示选择提示文字“请选择要盖放的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己墓地·除外状态选择1张满足s.setfilter的「魊影」陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 如果选择的对象在墓地，则设置CATEGORY_LEAVE_GRAVE操作信息，使涉及墓地的效果（如王家长眠之谷）能正确响应。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 效果②的处理：取得对象卡，若对象仍与效果关联，则将其盖放到自己魔法与陷阱区。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时锁定的对象卡（因为只选择1张，所以用GetFirstTarget）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡盖放到自己场上（魔法与陷阱区）。
		Duel.SSet(tp,tc)
	end
end
