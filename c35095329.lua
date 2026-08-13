--E-HERO ヴィシャス・クローズ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次，②的效果在决斗中只能使用1次。
-- ①：以场上1只「英雄」怪兽为对象才能发动。这张卡从手卡守备表示特殊召唤，作为对象的怪兽的攻击力上升300。
-- ②：自己场上的怪兽被战斗·效果破坏的场合才能发动。这张卡从墓地特殊召唤。那之后，自己墓地有着有「暗黑融合」的卡名记述的怪兽存在的场合，可以把场上1张卡破坏。
local s,id,o=GetID()
-- 注册此卡的两个效果：①为手卡发动的起动效果，②为墓地发动的诱发效果，并预先登记“暗黑融合”的卡名记述信息。
function s.initial_effect(c)
	-- 将“暗黑融合”的卡号94820406登记到本卡的记述列表中，使后续可通过aux.IsCodeListed判定“卡名记述了暗黑融合的怪兽”。
	aux.AddCodeList(c,94820406)
	-- ①：以场上1只「英雄」怪兽为对象才能发动。这张卡从手卡守备表示特殊召唤，作为对象的怪兽的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上的怪兽被战斗·效果破坏的场合才能发动。这张卡从墓地特殊召唤。那之后，自己墓地有着有「暗黑融合」的卡名记述的怪兽存在的场合，可以把场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 筛选条件：场上表侧表示且属于「英雄」字段的怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8)
end
-- ①效果的发动条件判定：确认这张卡可以从手卡守备表示特殊召唤、自己主要怪兽区有空位，并且场上存在可作为对象的表侧「英雄」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.cfilter(chkc) end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 确认自己的主要怪兽区域存在空格，用于特殊召唤这张卡。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认场上存在至少1只符合条件的表侧「英雄」怪兽可以被选择为对象。
		and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示“请选择表侧表示的卡”的提示消息，引导玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧「英雄」怪兽作为效果对象，并记录为当前连锁的对象。
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次操作信息为特殊召唤这张卡，供其他卡牌连锁判断使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：将自身从手卡守备表示特殊召唤，成功后再为对象怪兽附加攻击力上升300的效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取①效果选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认这张卡仍与发动效果关联，且能够特殊召唤，然后将其守备表示特殊召唤；若特殊召唤成功则继续给对象加攻击力。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0
		and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
			-- 作为对象的怪兽的攻击力上升300。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(300)
			tc:RegisterEffect(e1)
	end
end
-- 过滤条件：因战斗或效果被破坏、破坏前位于主要怪兽区且控制者为自己的怪兽。
function s.cspfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- ②效果的发动条件：本次破坏事件中存在自己场上的怪兽被战斗/效果破坏，且被破坏的怪兽中不包括这张卡自身。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cspfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- ②效果的发动判定：确认这张卡可以从墓地特殊召唤，并且自己主要怪兽区有空位。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己的主要怪兽区域有空位，用于从墓地特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 设置操作信息为从墓地特殊召唤这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义“卡名记述了暗黑融合的怪兽”的筛选条件，用于判断墓地中是否存在满足条件的怪兽。
function s.cdesfilter(c)
	-- 该怪兽必须满足：卡名记述中含有「暗黑融合」（通过aux.IsCodeListed判定），且卡种为怪兽卡。
	return aux.IsCodeListed(c,94820406) and c:IsType(TYPE_MONSTER)
end
-- ②效果处理：从墓地特殊召唤这张卡；若特殊召唤成功且墓地存在记载暗黑融合的怪兽，询问玩家是否破坏场上1张卡，选择后执行破坏。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果关联、不受王家长眠之谷影响，并成功从墓地特殊召唤到场上。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查自己墓地是否存在至少1张“卡名记述了暗黑融合的怪兽”，用于决定能否追加破坏效果。
		and Duel.IsExistingMatchingCard(s.cdesfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查场上是否存在可以作为破坏对象的卡。
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 询问玩家是否发动追加效果，将场上1张卡破坏。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡破坏？"
		-- 显示“请选择要破坏的卡”的提示，引导玩家选择破坏对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从场上双方所有卡中选择1张要破坏的卡。
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续的破坏处理与之前的特殊召唤不同时进行，避免错过时点。
			Duel.BreakEffect()
			-- 显示选中卡的被选为对象动画，并记录其为对象。
			Duel.HintSelection(g)
			-- 将选择的那张卡以这张卡的效果破坏送入墓地。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
