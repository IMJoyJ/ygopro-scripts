--花札衛－月花見－
-- 效果：
-- 调整＋调整以外的怪兽2只
-- ①：1回合1次，自己主要阶段才能发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以把那只怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽在这个回合可以直接攻击。这个效果发动的场合，下次的自己回合的抽卡阶段跳过。
-- ②：把场上的这张卡作为同调素材的场合，可以把包含这张卡的全部同调素材怪兽当作2星怪兽使用。
function c33541430.initial_effect(c)
	-- 为这张卡添加同调召唤手续，素材要求为1只调整＋2只调整以外的怪兽，且必须正好使用这3只。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),2,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己主要阶段才能发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以把那只怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽在这个回合可以直接攻击。这个效果发动的场合，下次的自己回合的抽卡阶段跳过。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33541430,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c33541430.drcost)
	e2:SetTarget(c33541430.drtg)
	e2:SetOperation(c33541430.drop)
	c:RegisterEffect(e2)
	-- ②：把场上的这张卡作为同调素材的场合，可以把包含这张卡的全部同调素材怪兽当作2星怪兽使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e3:SetTarget(c33541430.syntg)
	e3:SetValue(1)
	e3:SetOperation(c33541430.synop)
	c:RegisterEffect(e3)
	-- ②：把包含这张卡的全部同调素材怪兽当作2星怪兽使用。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(89818984)
	e4:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e4)
end
-- 作为效果发动代价，给己方场上注册一个跳过下次自己回合抽卡阶段的效果，从而在发动①后跳过抽卡阶段。
function c33541430.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- ①：这个效果发动的场合，下次的自己回合的抽卡阶段跳过。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以把那只怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCode(EFFECT_SKIP_DP)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	-- 将“跳过抽卡阶段”的永续效果注册到场上，使其作用于己方玩家，实现发动代价。
	Duel.RegisterEffect(e1,tp)
end
-- 效果发动的目标合法性检查：确认己方可以抽1张卡，并设定对象玩家为己方、对象参数为抽卡数1，同时登记抽卡操作信息。
function c33541430.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动合法性检查（chk==0），返回己方是否能抽1张卡；不能抽卡则效果不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为己方，表示由己方进行抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 登记本连锁包含“抽卡”类别的操作信息，指定由己方抽1张卡，供其他卡进行对应。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：按设定让己方抽1张并给对方确认；若抽到的是「花札卫」怪兽且己方场上有空位，则询问后将其无视召唤条件特殊召唤，并赋予直接攻击效果；最后洗切手卡。
function c33541430.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设定的对象玩家p和抽卡数d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡；若实际抽取成功（返回值不为0）则继续后续处理。
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		-- 从上次操作（抽卡）实际操作的卡片组中取出第一张卡，即抽到的那张卡。
		local tc=Duel.GetOperatedGroup():GetFirst()
		-- 将抽到的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
		-- 中断当前效果处理，使之后的特殊召唤等操作被视为新的时点，避免错过时点。
		Duel.BreakEffect()
		if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0xe6) then
			-- 检查己方场上是否存在可用的主要怪兽区空格。
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 询问己方玩家是否要将那只怪兽特殊召唤。
				and Duel.SelectYesNo(tp,aux.Stringid(33541430,1))  --"是否特殊召唤？"
				-- 在玩家选择是后，无视召唤条件将那只怪兽以表侧表示特殊召唤（作为特殊召唤步骤）。
				and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
				-- ①：这个效果特殊召唤的怪兽在这个回合可以直接攻击。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DIRECT_ATTACK)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1,true)
			end
			-- 结束特殊召唤步骤，完成所有特殊召唤处理。
			Duel.SpecialSummonComplete()
		end
		-- 洗切己方手卡，重置抽卡后的手卡排列状态。
		Duel.ShuffleHand(tp)
	end
end
-- 自定义函数：返回本卡作为同调素材时的等级为2，供效果②进行等级计算。
function c33541430.cardiansynlevel(c)
	return 2
end
-- 定义同调素材过滤条件：必须是表侧表示、可作为同调素材，并满足额外的过滤参数f。
function c33541430.synfilter(c,syncard,tuner,f)
	return c:IsFaceupEx() and c:IsCanBeSynchroMaterial(syncard,tuner) and (f==nil or f(c,syncard))
end
-- 递归检测：将一张候选卡暂时加入素材组后，判断是否已能达成同调召唤的星级条件，或还能继续追加其他候选素材。
function c33541430.syncheck(c,g,mg,tp,lv,syncard,minc,maxc)
	g:AddCard(c)
	local ct=g:GetCount()
	local res=c33541430.syngoal(g,tp,lv,syncard,minc,ct)
		or (ct<maxc and mg:IsExists(c33541430.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc))
	g:RemoveCard(c)
	return res
end
-- 判断当前素材组是否满足同调召唤要求：素材数量达标、额外怪兽区有空位、按原等级或视为2星计算的合计等级等于目标星级，且没有“必须作为素材”限制。
function c33541430.syngoal(g,tp,lv,syncard,minc,ct)
	-- 要求素材数量达到下限，并且把这些素材送墓后在额外怪兽区能空出特殊召唤同调怪兽的格子。
	return ct>=minc and Duel.GetLocationCountFromEx(tp,tp,g,syncard)>0
		and (g:CheckWithSumEqual(Card.GetSynchroLevel,lv,ct,ct,syncard)
			or g:CheckWithSumEqual(c33541430.cardiansynlevel,lv,ct,ct,syncard))
		-- 确认素材组中没有因“必须作为同调素材”等效果影响而无法作为素材使用的卡。
		and aux.MustMaterialCheck(g,tp,EFFECT_MUST_BE_SMATERIAL)
end
-- 效果②的触发判定：当本卡作为同调素材时，判断能否在包含本卡的情况下选出足够素材，使等级（可按2星计算）满足同调召唤条件。
function c33541430.syntg(e,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local tp=syncard:GetControler()
	local lv=syncard:GetLevel()
	if lv<=c:GetLevel() and lv<=c33541430.cardiansynlevel(c) then return false end
	local g=Group.FromCards(c)
	-- 获取同调召唤可用的素材候选，过滤出满足条件的卡（排除本卡自身，因为本卡已作为必含素材单独加入）。
	local mg=Duel.GetSynchroMaterial(tp):Filter(c33541430.synfilter,c,syncard,c,f)
	return mg:IsExists(c33541430.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc)
end
-- 效果②的处理：在候选素材中循环选择必要的卡，直到满足同调召唤条件，将最终确定的素材组设为同调素材。
function c33541430.synop(e,tp,eg,ep,ev,re,r,rp,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local lv=syncard:GetLevel()
	local g=Group.FromCards(c)
	-- 获取可用的同调素材候选并过滤满足条件的卡，排除本卡自身。
	local mg=Duel.GetSynchroMaterial(tp):Filter(c33541430.synfilter,c,syncard,c,f)
	for i=1,maxc do
		local cg=mg:Filter(c33541430.syncheck,g,g,mg,tp,lv,syncard,minc,maxc)
		if cg:GetCount()==0 then break end
		local minct=1
		if c33541430.syngoal(g,tp,lv,syncard,minc,i) then
			minct=0
		end
		-- 向玩家显示“选择同调素材”的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
		local sg=cg:Select(tp,minct,1,nil)
		if sg:GetCount()==0 then break end
		g:Merge(sg)
	end
	-- 将最终选出的素材组设置为本次同调召唤要使用的同调素材。
	Duel.SetSynchroMaterial(g)
end
