--タツネクロ
-- 效果：
-- 通常召唤的这张卡为素材作同调召唤的场合，手卡1只怪兽也能作为同调素材。那个时候的同调素材怪兽不去墓地而除外。
-- ①：只要这张卡在怪兽区域存在，自己不是不死族怪兽不能特殊召唤。
function c3096468.initial_effect(c)
	-- 通常召唤的这张卡为素材作同调召唤的场合，手卡1只怪兽也能作为同调素材。那个时候的同调素材怪兽不去墓地而除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c3096468.syncon)
	e1:SetTarget(c3096468.syntg)
	e1:SetValue(1)
	e1:SetOperation(c3096468.synop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，自己不是不死族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c3096468.splimit)
	c:RegisterEffect(e2)
	-- 通常召唤的这张卡为素材作同调召唤的场合，手卡1只怪兽也能作为同调素材。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e3:SetCondition(c3096468.syncon)
	e3:SetCode(EFFECT_HAND_SYNCHRO)
	e3:SetTargetRange(0,1)
	c:RegisterEffect(e3)
end
-- 筛选可作为同调素材的怪兽：要求为表侧表示（或可确认的手牌怪兽）、能够成为该同调怪兽的同调素材，并满足追加过滤条件f。
function c3096468.synfilter(c,syncard,tuner,f)
	return c:IsFaceupEx() and c:IsCanBeSynchroMaterial(syncard,tuner) and (f==nil or f(c,syncard))
end
-- 递归回溯判定：将候选卡c加入当前素材组g后，检查该组合是否已满足同调条件；若未满足且素材数未满，再尝试从其余候选卡中递归加入下一张。无论结果如何，最后将c移出g以恢复状态。
function c3096468.syncheck(c,g,mg,tp,lv,syncard,minc,maxc)
	g:AddCard(c)
	local ct=g:GetCount()
	local res=c3096468.syngoal(g,tp,lv,syncard,minc,ct)
		or (ct<maxc and mg:IsExists(c3096468.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc))
	g:RemoveCard(c)
	return res
end
-- 判定素材组g是否满足同调召唤的要求：素材数不少于最低数量，各素材的同调星级之和等于同调怪兽等级，额外怪兽区有空位，手牌素材不超过1张，且通过必须作为同调素材的限制检查。
function c3096468.syngoal(g,tp,lv,syncard,minc,ct)
	return ct>=minc
		and g:CheckWithSumEqual(Card.GetSynchroLevel,lv,ct,ct,syncard)
		-- 检查若使用素材组g进行同调召唤，额外怪兽区是否有空位来特殊召唤该同调怪兽。
		and Duel.GetLocationCountFromEx(tp,tp,g,syncard)>0
		and g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)<=1
		-- 检查素材组g中是否存在受到‘必须作为同调素材’效果影响的卡，并确认这些卡的使用符合该效果限制。
		and aux.MustMaterialCheck(g,tp,EFFECT_MUST_BE_SMATERIAL)
end
-- 该自定义同调素材效果的条件：这张卡为通常召唤出场时才能适用。
function c3096468.syncon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 自定义同调素材的可用性判定：将通常召唤的这张卡作为必选素材，并加入场上及手牌中可用的同调素材候选，通过递归检查确定是否存在一组素材能满足同调召唤的等级、数量、额外区空格等条件。
function c3096468.syntg(e,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local tp=syncard:GetControler()
	local lv=syncard:GetLevel()
	if lv<=c:GetLevel() then return false end
	local g=Group.FromCards(c)
	-- 获取场上现有的通常同调素材（调整与非调整），排除这张卡自身后，筛选出可作为该同调怪兽素材的卡。
	local mg=Duel.GetSynchroMaterial(tp):Filter(c3096468.synfilter,c,syncard,c,f)
	-- 获取手牌中可作为该同调怪兽同调素材的怪兽（排除这张卡自身），用于实现‘手卡1只怪兽也能作为同调素材’。
	local exg=Duel.GetMatchingGroup(c3096468.synfilter,tp,LOCATION_HAND,0,c,syncard,c,f)
	mg:Merge(exg)
	return mg:IsExists(c3096468.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc)
end
-- 执行同调素材的选择：先取得可用素材候选组，循环让玩家选择要加入的素材，直到素材组满足同调条件或无法继续选择；如果素材组中包含了手牌怪兽，则为这些怪兽赋予‘作为同调素材的场合不去墓地而除外’的替代效果；最后将完整素材组设为本次同调召唤的素材。
function c3096468.synop(e,tp,eg,ep,ev,re,r,rp,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local lv=syncard:GetLevel()
	local g=Group.FromCards(c)
	-- 获取场上所有可作为同调素材的候选怪兽（排除这张卡自身），为实际选择素材做准备。
	local mg=Duel.GetSynchroMaterial(tp):Filter(c3096468.synfilter,c,syncard,c,f)
	-- 获取手牌中可作为同调素材的候选怪兽（排除这张卡自身），以支持选择手牌怪兽作为第2只以上素材。
	local exg=Duel.GetMatchingGroup(c3096468.synfilter,tp,LOCATION_HAND,0,c,syncard,c,f)
	mg:Merge(exg)
	for i=1,maxc do
		local cg=mg:Filter(c3096468.syncheck,g,g,mg,tp,lv,syncard,minc,maxc)
		if cg:GetCount()==0 then break end
		local minct=1
		if c3096468.syngoal(g,tp,lv,syncard,minc,i) then
			minct=0
		end
		-- 显示‘请选择要作为同调素材的卡’的提示，要求当前玩家选择同调素材。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
		local sg=cg:Select(tp,minct,1,nil)
		if sg:GetCount()==0 then break end
		g:Merge(sg)
	end
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
		-- 遍历最终素材组g中的每张卡，准备为需要改送去向的素材（手牌怪兽）逐一赋予除外替代效果。
		for tc in aux.Next(g) do
			-- 那个时候的同调素材怪兽不去墓地而除外。①：只要这张卡在怪兽区域存在，自己不是不死族怪兽不能特殊召唤。
			local e1=Effect.CreateEffect(c)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			tc:RegisterEffect(e1,true)
		end
	end
	-- 将最终确定的素材组g设置为本次同调召唤使用的同调素材。
	Duel.SetSynchroMaterial(g)
end
-- 限制玩家只能特殊召唤不死族怪兽；若怪兽的种族不是不死族，则不能进行特殊召唤。
function c3096468.splimit(e,c)
	return not c:IsRace(RACE_ZOMBIE)
end
