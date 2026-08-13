--幻獣機グリーフィン
-- 效果：
-- 自己的主要阶段时，把自己场上2只名字带有「幻兽机」的怪兽解放才能发动。这张卡从手卡特殊召唤。「幻兽机 加里宁狮鹫」的这个效果1回合只能使用1次。只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。此外，1回合1次，把手卡1只名字带有「幻兽机」的怪兽丢弃才能发动。把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
function c41329458.initial_effect(c)
	-- 自己的主要阶段时，把自己场上2只名字带有「幻兽机」的怪兽解放才能发动。这张卡从手卡特殊召唤。「幻兽机 加里宁狮鹫」的这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41329458,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,41329458)
	e1:SetCost(c41329458.spcost)
	e1:SetTarget(c41329458.sptg)
	e1:SetOperation(c41329458.spop)
	c:RegisterEffect(e1)
	-- 只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 设置该效果的适用条件：己方场上有衍生物存在时，抗性效果才适用。
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- 此外，1回合1次，把手卡1只名字带有「幻兽机」的怪兽丢弃才能发动。把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(41329458,1))  --"特召衍生物"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c41329458.spcost2)
	e4:SetTarget(c41329458.sptg2)
	e4:SetOperation(c41329458.spop2)
	c:RegisterEffect(e4)
end
-- 筛选用于解放的怪兽：必须为名字带有「幻兽机」的怪兽，且是自己控制的怪兽或表侧表示的怪兽，以保证可以将其解放。
function c41329458.rfilter(c,tp)
	return c:IsSetCard(0x101b) and (c:IsControler(tp) or c:IsFaceup())
end
-- 第一个效果的代价：从满足条件的怪兽中选择2只名字带有「幻兽机」的怪兽解放，作为特殊召唤这张卡的发动代价。
function c41329458.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前玩家所有可解放的怪兽组，再过滤出符合rfilter条件的「幻兽机」怪兽。
	local rg=Duel.GetReleaseGroup(tp):Filter(c41329458.rfilter,nil,tp)
	-- 在代价检查阶段，确认存在2只怪兽，且解放后主怪兽区仍有空位并能够正常解放（满足特召条件）。
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	-- 弹出选择提示，让玩家选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从符合条件的怪兽中选出2只，同时持续检查解放后仍有空位；选择完成后返回选中的怪兽组。
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	-- 若使用了代替解放的效果（如暗影敌托邦），在此消耗其额外的解放次数。
	aux.UseExtraReleaseCount(g,tp)
	-- 将选中的2只怪兽作为发动代价解放（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- 第一个效果的目标函数：效果发动时检查这张卡能否被特殊召唤，并进行相应设定。
function c41329458.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息：本次特殊召唤的对象为这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 第一个效果的处理函数：若这张卡仍与效果关联，则将其特殊召唤。
function c41329458.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧攻击表示特殊召唤到己方场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 筛选可用于丢弃的「幻兽机」怪兽：手卡中名字带有「幻兽机」、为怪兽卡且可以被丢弃。
function c41329458.cfilter(c)
	return c:IsSetCard(0x101b) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 第二个效果的代价：从手卡丢弃1只满足cfilter条件的「幻兽机」怪兽作为发动代价。
function c41329458.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段，确认手卡中存在至少1张满足条件的「幻兽机」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c41329458.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃：让玩家从手卡选择1只满足条件的「幻兽机」怪兽丢弃（计为代价及丢弃）。
	Duel.DiscardHand(tp,c41329458.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 第二个效果的目标函数：效果发动时确认主怪兽区有空位且玩家能够特殊召唤「幻兽机衍生物」。
function c41329458.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主怪兽区是否存在空位（大于0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能够以表侧表示特殊召唤符合参数的「幻兽机衍生物」（3星、机械族、风属性、攻/守0的衍生物）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) end
	-- 设置衍生物生成的操作信息：本效果将生成1只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置特殊召唤的操作信息：本效果将特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 第二个效果的处理函数：若仍满足条件，则生成并特殊召唤1只「幻兽机衍生物」。
function c41329458.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主怪兽区还有空位，若无空位则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 处理时再次确认玩家仍能特殊召唤该衍生物，避免处理时条件变化导致无法特殊召唤。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 创建1只「幻兽机衍生物」（衍生物卡号41329459）的token。
		local token=Duel.CreateToken(tp,41329459)
		-- 将生成的衍生物以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
