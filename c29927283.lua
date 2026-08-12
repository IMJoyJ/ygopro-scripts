--新世竜ダニアン
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡用怪兽的效果特殊召唤的场合才能发动。从卡组把1只「基因组混合」怪兽加入手卡。
-- ②：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只恐龙族融合怪兽融合召唤。
-- ③：这张卡被送去墓地的场合才能发动。自己场上的全部恐龙族怪兽的攻击力上升400。
local s,id,o=GetID()
-- 初始化这张卡的3个效果：e1为用怪兽效果特殊召唤成功时发动的检索效果，e2为自己主要阶段在场上发动的融合召唤起动效果，e3为被送去墓地时发动的攻击力上升效果，各自设置1回合1次的次数限制并注册到这张卡上
function s.initial_effect(c)
	-- ①：这张卡用怪兽的效果特殊召唤的场合才能发动。从卡组把1只「基因组混合」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只恐龙族融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.fsptg)
	e2:SetOperation(s.fspop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合才能发动。自己场上的全部恐龙族怪兽的攻击力上升400。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"攻击力上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：判定这次特殊召唤是否由怪兽的效果造成（诱发该特殊召唤的效果是怪兽效果）
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 检索对象过滤器：判定卡是否为「基因组混合」（字段0x1dd）的怪兽卡且可以加入手卡
function s.thfilter(c)
	return c:IsSetCard(0x1dd) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的对象确认处理：发动条件检查卡组是否存在可检索的「基因组混合」怪兽，之后向对方提示效果发动，并设置将1张卡从卡组加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1只可以加入手卡的「基因组混合」怪兽，存在才满足发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示我方选择了发动「检索」效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：预计以效果将1张卡从自己卡组加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：让玩家从卡组选择1只「基因组混合」怪兽加入手卡，加入成功则向对方展示该卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1只满足条件的「基因组混合」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选中的卡以效果原因加入其持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示（确认）加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 融合素材过滤器：判定作为素材的卡是否不受这个效果影响（不受影响的卡不能作为素材）
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 融合怪兽过滤器：判定额外卡组的卡是否为恐龙族融合怪兽、满足附加条件、可以融合召唤方式特殊召唤、且能用给定的素材组进行融合召唤
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DINOSAUR) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ②效果的对象确认处理：发动条件检查是否存在能用自己手卡·场上怪兽作素材融合召唤的恐龙族融合怪兽（没有则再检查连锁素材的情况），之后提示发动并设置从额外卡组特殊召唤1只怪兽的操作信息
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 取得自己可用的融合素材（手卡·场上的怪兽），并过滤掉不受此效果影响的卡
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 检查额外卡组是否存在能用上述素材融合召唤的恐龙族融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 取得玩家受到的「连锁素材」效果（用于改变融合素材的取得方式）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 用连锁素材提供的素材组再次检查额外卡组是否存在可以融合召唤的恐龙族融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 向对方玩家提示我方选择了发动「融合召唤」效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：预计从自己额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理：收集通常素材与连锁素材下可融合召唤的恐龙族融合怪兽，让玩家选择1只；若走通常素材则由玩家选择素材送去墓地并融合召唤，若走连锁素材则执行连锁素材的操作代替，最后完成召唤手续
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 取得自己可用的融合素材（手卡·场上的怪兽），并过滤掉不受此效果影响的卡
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 从额外卡组取得能用通常素材融合召唤的全部恐龙族融合怪兽
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 取得玩家受到的「连锁素材」效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 从额外卡组取得能用连锁素材提供的素材组融合召唤的全部恐龙族融合怪兽
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示发动玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选怪兽是否用通常素材进行融合召唤：属于通常素材组且（不属于连锁素材组，或玩家对是否使用连锁素材选择了否）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从通常素材组中选择用于该融合召唤的一组融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 把作为融合素材的卡以效果·素材·融合原因送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使送去墓地与之后的特殊召唤视为不同时处理
			Duel.BreakEffect()
			-- 把选中的恐龙族融合怪兽以融合召唤方式表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 让玩家从连锁素材提供的素材组中选择用于该融合召唤的一组融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 攻击力上升对象过滤器：判定怪兽是否为自己场上表侧表示的恐龙族怪兽
function s.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
-- ③效果的对象确认处理：发动条件检查自己场上是否存在表侧表示的恐龙族怪兽
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的恐龙族怪兽，存在才满足发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- ③效果的处理：取得自己场上全部表侧表示的恐龙族怪兽，逐个给它们注册攻击力上升400的永续效果（不可无效，直到离场等重置）
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己场上全部表侧表示的恐龙族怪兽
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历这组恐龙族怪兽中的每一张卡
	for tc in aux.Next(g) do
		-- 自己场上的全部恐龙族怪兽的攻击力上升400。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
