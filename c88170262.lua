--キラーチューン・リミックス
-- 效果：
-- 「杀手级调整曲·混音手」＋调整1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要对方的场上或墓地有调整存在，这张卡的攻击力上升1500。
-- ②：对方回合，把这张卡解放才能发动。从自己墓地选同调怪兽以外的2只调整，那之内的1只加入手卡，另1只特殊召唤。那之后，可以进行1只同调怪兽调整的同调召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册同调召唤手续、攻击力上升效果、解放自身特召/检索墓地调整的效果以及素材检查效果。
function s.initial_effect(c)
	-- 将「杀手级调整曲·混音手」（卡号16509007）加入该卡的素材代码列表。
	aux.AddMaterialCodeList(c,16509007)
	-- 添加同调召唤手续：以「杀手级调整曲·混音手」为非调整，1只以上的调整怪兽为素材。
	aux.AddSynchroMixProcedure(c,aux.FilterBoolFunction(Card.IsCode,16509007),nil,nil,aux.Tuner(nil),1,99)
	c:EnableReviveLimit()
	-- ①：只要对方的场上或墓地有调整存在，这张卡的攻击力上升1500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.atkcon)
	e1:SetValue(1500)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：对方回合，把这张卡解放才能发动。从自己墓地选同调怪兽以外的2只调整，那之内的1只加入手卡，另1只特殊召唤。那之后，可以进行1只同调怪兽调整的同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 「杀手级调整曲·混音手」＋调整1只以上
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	c:RegisterEffect(e3)
end
-- 检查同调素材中是否包含2只以上的调整怪兽，若是则给自身注册对应的标记效果。
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,2,nil,TYPE_TUNER) then
		-- 「杀手级调整曲·混音手」＋调整1只以上
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(21142671)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤对方场上或墓地表侧表示存在的调整怪兽。
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_TUNER)
end
-- 攻击力上升效果的发动条件：对方的场上或墓地有调整存在。
function s.atkcon(e)
	-- 检查对方的场上或墓地是否存在至少1只表侧表示的调整怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandler():GetControler(),0,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
end
-- 效果②的发动条件：对方回合。
function s.spcon(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前回合玩家是否为对方。
	return Duel.GetTurnPlayer()==1-tp
end
-- 效果②的发动代价：把这张卡解放。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤自己墓地中同调怪兽以外的、可以特殊召唤或加入手卡的调整怪兽。
function s.thfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and not c:IsType(TYPE_SYNCHRO)
		and (c:IsCanBeSpecialSummoned(e,0,tp,false,false) or c:IsAbleToHand())
end
-- 辅助过滤函数：检查选定的2只怪兽中，其中1只可以特殊召唤，且剩下的另1只可以加入手卡。
function s.thfilter2(c,g,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g:FilterCount(Card.IsAbleToHand,c)==1
end
-- 检查选定的2只怪兽是否满足“1只加入手卡，另1只特殊召唤”的条件。
function s.sporthGroup(g,e,tp)
	return g:FilterCount(s.thfilter2,nil,g,e,tp)~=0
end
-- 效果②的靶向与可行性检查：确认自己墓地存在满足条件的2只调整，并设置特殊召唤与加入手卡的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己墓地中所有满足条件的同调怪兽以外的调整怪兽。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 检查发动时自己场上是否有可用的怪兽区域，且墓地中是否存在可以进行“1只特召、1只检索”的2只调整怪兽。
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0 and g:CheckSubGroup(s.sporthGroup,2,2,e,tp) end
	-- 设置特殊召唤的操作信息，预计从墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	-- 设置加入手卡的操作信息，预计从墓地将1只卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 过滤额外卡组中可以进行同调召唤的同调怪兽调整。
function s.spfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsSynchroSummonable(nil)
end
-- 过滤选定的2只怪兽中可以加入手卡，且剩下的另1只可以特殊召唤的怪兽。
function s.rthfilter(c,tp,e,g)
	return c:IsAbleToHand() and g:FilterCount(Card.IsCanBeSpecialSummoned,c,e,0,tp,false,false)==1
end
-- 效果②的效果处理：从墓地选择2只调整，将1只加入手卡，另1只特殊召唤，之后可以进行同调怪兽调整的同调召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地中不受「王家长眠之谷」影响的、满足条件的同调怪兽以外的调整怪兽。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 提示玩家选择效果的对象（此处用于选择墓地的2只调整怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,s.sporthGroup,false,2,2,e,tp)
	if sg then
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tc=sg:FilterSelect(tp,s.rthfilter,1,1,nil,tp,e,sg):GetFirst()
		-- 将选中的其中1只调整怪兽加入手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片。
		Duel.ConfirmCards(1-tp,tc)
		sg:RemoveCard(tc)
		-- 将剩下的另1只调整怪兽在自己场上表侧表示特殊召唤，并检查是否特殊召唤成功。
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 立即刷新场上卡片的状态与信息。
			Duel.AdjustAll()
			-- 检查额外卡组是否存在可以进行同调召唤的同调怪兽调整。
			if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil)
				-- 询问玩家是否进行同调召唤。
				and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否同调召唤？"
				-- 中断当前效果处理，使后续的同调召唤不与前面的特殊召唤视为同时处理。
				Duel.BreakEffect()
				-- 获取额外卡组中所有可以进行同调召唤的同调怪兽调整。
				local exg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil)
				if exg:GetCount()>0 then
					-- 提示玩家选择要进行同调召唤的怪兽。
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					local syg=exg:Select(tp,1,1,nil)
					-- 对选中的怪兽进行同调召唤。
					Duel.SynchroSummon(tp,syg:GetFirst(),nil)
				end
			end
		end
	end
end
