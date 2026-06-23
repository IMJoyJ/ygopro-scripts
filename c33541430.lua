--花札衛－月花見－
-- 效果：
-- 调整＋调整以外的怪兽2只
-- ①：1回合1次，自己主要阶段才能发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以把那只怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽在这个回合可以直接攻击。这个效果发动的场合，下次的自己回合的抽卡阶段跳过。
-- ②：把场上的这张卡作为同调素材的场合，可以把包含这张卡的全部同调素材怪兽当作2星怪兽使用。
function c33541430.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和2只调整以外的怪兽作为同调素材
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
	-- 此卡不能被对方的魔法效果选择为对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(89818984)
	e4:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e4)
end
-- 效果发动时，跳过自己下个回合的抽卡阶段
function c33541430.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将跳过抽卡阶段的效果注册给全局环境
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCode(EFFECT_SKIP_DP)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	-- 将跳过抽卡阶段的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 设置效果的目标玩家为使用者
function c33541430.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家为使用者
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为1
	Duel.SetTargetParam(1)
	-- 设置效果操作信息为抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理抽卡效果，确认抽到的卡并判断是否为花札卫怪兽，若是则可特殊召唤
function c33541430.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，若抽到卡则继续处理
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		-- 获取抽卡操作实际处理的卡片组中的第一张卡
		local tc=Duel.GetOperatedGroup():GetFirst()
		-- 向对方确认抽到的卡
		Duel.ConfirmCards(1-tp,tc)
		-- 中断当前效果处理
		Duel.BreakEffect()
		if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0xe6) then
			-- 检查是否有足够的怪兽区域
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 询问玩家是否特殊召唤
				and Duel.SelectYesNo(tp,aux.Stringid(33541430,1))  --"是否特殊召唤？"
				-- 执行特殊召唤操作
				and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
				-- 为特殊召唤的怪兽设置直接攻击效果
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DIRECT_ATTACK)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1,true)
			end
			-- 完成特殊召唤流程
			Duel.SpecialSummonComplete()
		end
		-- 洗切玩家手牌
		Duel.ShuffleHand(tp)
	end
end
-- 定义该卡的同调等级为2
function c33541430.cardiansynlevel(c)
	return 2
end
-- 过滤满足条件的同调素材怪兽
function c33541430.synfilter(c,syncard,tuner,f)
	return c:IsFaceupEx() and c:IsCanBeSynchroMaterial(syncard,tuner) and (f==nil or f(c,syncard))
end
-- 递归检查是否能构成有效的同调召唤组合
function c33541430.syncheck(c,g,mg,tp,lv,syncard,minc,maxc)
	g:AddCard(c)
	local ct=g:GetCount()
	local res=c33541430.syngoal(g,tp,lv,syncard,minc,ct)
		or (ct<maxc and mg:IsExists(c33541430.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc))
	g:RemoveCard(c)
	return res
end
-- 判断当前组合是否满足同调召唤条件
function c33541430.syngoal(g,tp,lv,syncard,minc,ct)
	-- 检查当前组合是否满足最少同调素材数量要求
	return ct>=minc and Duel.GetLocationCountFromEx(tp,tp,g,syncard)>0
		and (g:CheckWithSumEqual(Card.GetSynchroLevel,lv,ct,ct,syncard)
			or g:CheckWithSumEqual(c33541430.cardiansynlevel,lv,ct,ct,syncard))
		-- 检查当前组合是否满足必须成为同调素材的条件
		and aux.MustMaterialCheck(g,tp,EFFECT_MUST_BE_SMATERIAL)
end
-- 判断是否能通过同调召唤
function c33541430.syntg(e,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local tp=syncard:GetControler()
	local lv=syncard:GetLevel()
	if lv<=c:GetLevel() and lv<=c33541430.cardiansynlevel(c) then return false end
	local g=Group.FromCards(c)
	-- 获取所有可用的同调素材
	local mg=Duel.GetSynchroMaterial(tp):Filter(c33541430.synfilter,c,syncard,c,f)
	return mg:IsExists(c33541430.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc)
end
-- 处理同调召唤操作，选择同调素材并设置
function c33541430.synop(e,tp,eg,ep,ev,re,r,rp,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local lv=syncard:GetLevel()
	local g=Group.FromCards(c)
	-- 获取所有可用的同调素材
	local mg=Duel.GetSynchroMaterial(tp):Filter(c33541430.synfilter,c,syncard,c,f)
	for i=1,maxc do
		local cg=mg:Filter(c33541430.syncheck,g,g,mg,tp,lv,syncard,minc,maxc)
		if cg:GetCount()==0 then break end
		local minct=1
		if c33541430.syngoal(g,tp,lv,syncard,minc,i) then
			minct=0
		end
		-- 提示玩家选择同调素材
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
		local sg=cg:Select(tp,minct,1,nil)
		if sg:GetCount()==0 then break end
		g:Merge(sg)
	end
	-- 设置当前使用的同调素材组
	Duel.SetSynchroMaterial(g)
end
