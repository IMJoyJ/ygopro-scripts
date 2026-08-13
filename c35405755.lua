--俱利伽羅天童
-- 效果：
-- 这张卡不能通常召唤。把这个回合有在对方的怪兽区域把效果发动过的自己·对方场上的表侧表示怪兽全部解放的场合才能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升因为这张卡特殊召唤而解放的怪兽数量×1500。
-- ②：自己结束阶段，以对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册特殊召唤限制（不能通常召唤）、手牌特殊召唤手续（解放本回合在对方怪兽区域发动过效果的表侧怪兽）、②效果（结束阶段从对方墓地特召怪兽），并注册一个全局标记效果用于记录符合条件的怪兽。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把这个回合有在对方的怪兽区域把效果发动过的自己·对方场上的表侧表示怪兽全部解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.sprcon)
	e2:SetOperation(s.sprop)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己结束阶段，以对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		-- 把这个回合有在对方的怪兽区域把效果发动过的自己·对方场上的表侧表示怪兽全部解放的场合才能特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.checkop)
		-- 将记录效果发动情况的全局检查效果注册到场上（玩家0），使每次连锁处理结束时都能执行 checkop 来标记在对方怪兽区域发动过效果的怪兽。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 当一次连锁处理结束时，检查该连锁中发动效果的那只怪兽：若该怪兽是以表侧表示在对方怪兽区域发动效果，则给它打上标记，用于本回合识别“在对方怪兽区域发动过效果”的怪兽。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not rc:IsRelateToEffect(re) or not re:IsActiveType(TYPE_MONSTER) then return end
	-- 获取当前连锁发动效果的控制者和发动位置，用于判断是否为对方怪兽区域的效果发动。
	local p,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	if loc==LOCATION_MZONE and rc:GetFlagEffect(id+o+p)==0 then
		rc:RegisterFlagEffect(id+o+p,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 筛选表侧表示且带有指定控制者标记的怪兽，即符合“在对方怪兽区域发动过效果”条件的怪兽。
function s.rfilter(c,p)
	return c:IsFaceup() and c:GetFlagEffect(id+o+p)>0
end
-- 特殊召唤条件判断：必须存在至少1只符合条件的怪兽（本回合在对方怪兽区域发动过效果的表侧表示怪兽），全部都可以解放，且解放后自己场上仍有可用怪兽区空位；若场上有皇帝斗技场，还需额外检查场地空位限制。
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检索双方怪兽区域中，由对方控制且带有“本回合在对方怪兽区域发动过效果”标记的表侧表示怪兽，作为特殊召唤的解放候选。
	local rg=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,1-tp)
	-- 检查当前玩家是否受到皇帝斗技场的效果影响，以进行后续的场地空位限制判断。
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_KAISER_COLOSSEUM) then
		-- 统计自己主要怪兽区域当前存在的怪兽总数。
		local t1=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
		-- 统计对方主要怪兽区域当前存在的怪兽总数。
		local t2=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		-- 统计自己主要怪兽区域中，属于解放候选（在对方怪兽区域发动过效果）的怪兽数量。
		local r1=Duel.GetMatchingGroupCount(s.rfilter,tp,LOCATION_MZONE,0,nil,1-tp)
		-- 统计对方主要怪兽区域中，属于解放候选（在对方怪兽区域发动过效果）的怪兽数量。
		local r2=Duel.GetMatchingGroupCount(s.rfilter,tp,0,LOCATION_MZONE,nil,1-tp)
		if t1-r1+1 > t2-r2 then return false end
	end
	-- 返回特殊召唤条件是否满足：存在至少1只解放候选、所有候选怪兽均可解放，并且解放后自己的怪兽区域仍有空位。
	return rg:GetCount()>0 and rg:FilterCount(Card.IsReleasable,nil,REASON_SPSUMMON)==rg:GetCount() and aux.mzctcheck(rg,tp)
end
-- 特殊召唤手续的处理：将所有符合条件的表侧表示怪兽解放，并根据解放数量为这张卡赋予攻击力上升（解放数×1500）的效果，随后完成特殊召唤。
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 再次检索本次特殊召唤需要解放的全部符合条件的怪兽组，用于执行解放动作。
	local rg=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,1-tp)
	-- 以“特殊召唤”为理由解放检索到的所有怪兽，作为这张卡特殊召唤的召唤手续。
	Duel.Release(rg,REASON_SPSUMMON)
	-- ①：这张卡的攻击力上升因为这张卡特殊召唤而解放的怪兽数量×1500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(rg:GetCount()*1500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- ②效果的发动条件：当前回合必须是这张卡的控制者的结束阶段，即满足“自己结束阶段”。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否等于效果控制者，是则说明处于自己的结束阶段。
	return Duel.GetTurnPlayer()==tp
end
-- 判断目标怪兽是否能被效果特殊召唤到自己的场上，作为选择对象的合法性过滤条件。
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标选择与合法性判定：确认自己场上有可用怪兽区空位，并且对方墓地存在1只可被特殊召唤的怪兽，然后选择其中1只为对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.spfilter(chkc,e,tp) end
	-- 效果发动时（chk==0）先确认自己场上有可用的怪兽区空位，否则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认对方墓地存在至少1只满足特殊召唤条件的怪兽，可以作为本效果的对象。
		and Duel.IsExistingTarget(s.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示信息，用于选择对象时的界面引导。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从对方墓地选择1只符合条件的怪兽，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置本连锁的操作信息为“特殊召唤1只怪兽”，供规则上需要确认效果分类的场合使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：取得之前选择的对象怪兽，若它仍与本次效果相关，则以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中已经选择的1只对象怪兽，即对方墓地的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到这张卡控制者的场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
