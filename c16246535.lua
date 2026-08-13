--沈黙のサイコマジシャン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合，以自己的墓地·除外状态的1只4星以下的念动力族怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以让那只怪兽的等级上升1星。这个回合，自己不是念动力族怪兽不能从额外卡组特殊召唤。
-- ②：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
local s,id,o=GetID()
-- 初始化卡片的全部效果：添加同调召唤手续（调整+调整以外怪兽1只以上）并赋予苏生限制；注册①特殊召唤成功时的诱发效果（从自己墓地/除外特殊召唤4星以下念动力族，可选上升等级，附带额外卡组自肃）和②作为同调素材时可当作调整以外的永续效果。
function s.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整（nil表示任意调整）＋1只以上调整以外怪兽（aux.NonTuner(nil)表示任意调整以外怪兽），即通常的同调素材要求。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合，以自己的墓地·除外状态的1只4星以下的念动力族怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以让那只怪兽的等级上升1星。这个回合，自己不是念动力族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_NONTUNER)
	e2:SetValue(s.tnval)
	c:RegisterEffect(e2)
end
-- ①效果的对象过滤函数：筛选自己墓地·除外状态、表侧表示（墓地/除外中的卡默认为表侧）、4星以下念动力族且满足特殊召唤条件的怪兽。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_PSYCHO) and c:IsLevelBelow(4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件与目标指定：连锁确认时，检查对象是否为自己墓地/除外的合法目标；发动时，检查自己主要怪兽区有空位且存在至少1只满足s.spfilter的对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 发动条件之一：自己场上需要有空的区域用于特殊召唤对象怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：自己的墓地·除外状态中必须存在至少1只满足s.spfilter过滤条件（4星以下念动力族且可特殊召唤）的卡，才能以该卡为对象发动。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向玩家显示选择提示框，提示文案为“请选择要特殊召唤的卡”，用于接下来选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地·除外状态选择1只满足s.spfilter的怪兽，将其设为效果的对象（同时记录为连锁对象）。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 登记操作信息：本次效果将进行特殊召唤，对象为g（数量1），以便其他卡能正确响应/检测该特殊召唤操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的处理：取得对象卡；若对象仍与连锁有关且不受王家长眠之谷影响，则将其表侧表示特殊召唤；若特殊召唤成功，询问玩家是否让其等级上升1星，选择是则中断当前处理并给对象注册等级+1效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的目标怪兽（因为只选了1只，直接用GetFirstTarget获取）。
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否仍与当前连锁相关联（没有离场或效果被重置），且不受“王家长眠之谷”效果影响（即不能被从墓地特殊召唤的限制）。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc)
		-- 将目标怪兽表侧表示特殊召唤到自己场上；只有特殊召唤成功（返回值不为0）时才继续执行后续选项。
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 在特殊召唤成功后，询问玩家是否发动追加效果：让那只怪兽的等级上升1星。只有选择“是”才进入等级上升处理。
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否上升等级？"
		-- 中断当前效果处理，使后面的等级上升效果作为单独的处理进行，避免错过时点。
		Duel.BreakEffect()
		-- 那之后，可以让那只怪兽的等级上升1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
	-- 这个回合，自己不是念动力族怪兽不能从额外卡组特殊召唤。②：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果（不能从额外卡组特殊召唤非念动力族怪兽）注册给玩家tp，持续到结束阶段（RESET_PHASE+PHASE_END），实现“这个回合”的限制。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的过滤函数：当被特殊召唤的怪兽位于额外卡组且不是念动力族时，禁止该特殊召唤。
function s.splimit(e,c)
	return not c:IsRace(RACE_PSYCHO) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的价值函数：当这张卡与同调素材的另一只怪兽的控制者相同（即都在自己场上作为素材）时，返回真，允许这张卡当作调整以外的怪兽。
function s.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end
