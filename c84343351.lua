--クリスタルクリアウィング・オーバー・シンクロ・ドラゴン
-- 效果：
-- 调整2只以上或者同调怪兽调整＋「幻透翼同调龙」
-- 这张卡不用同调召唤不能特殊召唤。
-- ①：1回合1次，其他卡的效果发动时才能发动。那个发动无效并破坏。这个效果把怪兽破坏的场合，这张卡的攻击力直到回合结束时上升那个原本攻击力数值。
-- ②：同调召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。从额外卡组把1只「幻透翼」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片的全局效果，包括同调召唤手续、素材检查、特殊召唤限制、效果①（无效并破坏并增加攻击力）以及效果②（因对方离场时从额外卡组特召）。
function s.initial_effect(c)
	aux.AddMaterialCodeList(c,82044279)
	c:EnableReviveLimit()
	-- 注册同调召唤手续：以「幻透翼同调龙」为非调整，搭配调整怪兽，并使用自定义过滤函数进行素材合法性检查。
	aux.AddSynchroMixProcedure(c,aux.FilterBoolFunction(Card.IsCode,82044279),nil,nil,aux.Tuner(nil),1,99,s.syncheck)
	-- 调整2只以上或者同调怪兽调整＋「幻透翼同调龙」
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	-- 这张卡不用同调召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为只能通过同调召唤进行特殊召唤。
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，其他卡的效果发动时才能发动。那个发动无效并破坏。这个效果把怪兽破坏的场合，这张卡的攻击力直到回合结束时上升那个原本攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	-- ②：同调召唤的表侧表示的这张卡因对方从场上离开的场合才能发动。从额外卡组把1只「幻透翼」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 检查同调素材，若素材中存在2只以上的调整怪兽，则给自身注册一个特定的效果标记，用于后续其他卡片判定其是否由2只以上调整同调召唤而来。
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,2,nil,TYPE_TUNER) then
		-- 调整2只以上或者同调怪兽调整＋「幻透翼同调龙」
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(21142671)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤同调素材中的「幻透翼同调龙」，并检查其余素材是否满足“存在至少1只同调怪兽”或“非「幻透翼同调龙」的素材数量大于等于2只”的条件。
function s.mfilter2(c,mg,syncard)
	return c:IsCode(82044279) and (mg:IsExists(Card.IsType,1,c,TYPE_SYNCHRO) or #mg-1>=2) and not mg:IsExists(s.chkfilter,1,c,syncard)
end
-- 过滤不是调整怪兽的卡片。
function s.chkfilter(c,syncard)
	return not c:IsTuner(syncard)
end
-- 同调素材合法性检查函数，判断素材组中是否存在满足条件的「幻透翼同调龙」及其他素材。
function s.syncheck(g,syncard)
	return g:IsExists(s.mfilter2,1,nil,g,syncard)
end
-- 效果①的发动条件：自身未在战斗中被破坏，且当前连锁中存在可以被无效的发动。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否未被战斗破坏，且当前连锁的发动可以被无效。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 效果①的靶向/发动准备：设置无效发动和破坏卡片的操作信息。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为“使发动无效”。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置当前连锁的操作信息为“破坏发动效果的卡”。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果①的效果处理：使发动无效并破坏，若破坏了怪兽，则使自身攻击力上升该怪兽原本攻击力的数值。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 尝试无效发动并破坏该卡，若成功破坏且该卡原本攻击力大于等于0，则继续进行后续的攻击力上升处理。
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) and Duel.Destroy(rc,REASON_EFFECT)~=0 and rc:GetBaseAttack()>=0
		and not rc:IsPreviousLocation(LOCATION_SZONE) and (rc:IsPreviousLocation(LOCATION_MZONE) or rc:GetOriginalType()&TYPE_MONSTER~=0)
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力直到回合结束时上升那个原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(rc:GetBaseAttack())
		c:RegisterEffect(e1)
	end
end
-- 效果②的发动条件：同调召唤的表侧表示的自身因对方从场上离开。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 过滤额外卡组中可以特殊召唤的「幻透翼」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xff) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组怪兽特殊召唤所需的额外怪兽区域或主要怪兽区域是否有空位。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果②的发动准备：检查额外卡组是否存在可特召的「幻透翼」怪兽，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查额外卡组是否存在至少1只满足特召条件的「幻透翼」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为“从额外卡组特殊召唤1只怪兽”。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的效果处理：从额外卡组选择1只「幻透翼」怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，要求选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的「幻透翼」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
