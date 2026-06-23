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
	-- 只要这张卡在怪兽区域存在，自己不是不死族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c3096468.splimit)
	c:RegisterEffect(e2)
	-- 通常召唤的这张卡为素材作同调召唤的场合，手卡1只怪兽也能作为同调素材。那个时候的同调素材怪兽不去墓地而除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e3:SetCondition(c3096468.syncon)
	e3:SetCode(EFFECT_HAND_SYNCHRO)
	e3:SetTargetRange(0,1)
	c:RegisterEffect(e3)
end
-- 过滤满足同调条件的怪兽，包括是否能作为同调素材、是否为表侧表示、是否满足自定义条件f。
function c3096468.synfilter(c,syncard,tuner,f)
	return c:IsFaceupEx() and c:IsCanBeSynchroMaterial(syncard,tuner) and (f==nil or f(c,syncard))
end
-- 递归检查是否能组成满足条件的同调素材组合，用于判断是否可以进行同调召唤。
function c3096468.syncheck(c,g,mg,tp,lv,syncard,minc,maxc)
	g:AddCard(c)
	local ct=g:GetCount()
	local res=c3096468.syngoal(g,tp,lv,syncard,minc,ct)
		or (ct<maxc and mg:IsExists(c3096468.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc))
	g:RemoveCard(c)
	return res
end
-- 判断当前同调素材组合是否满足同调召唤的条件，包括数量、等级总和、场地空位、手牌数量限制和必须作为同调素材的检测。
function c3096468.syngoal(g,tp,lv,syncard,minc,ct)
	return ct>=minc
		and g:CheckWithSumEqual(Card.GetSynchroLevel,lv,ct,ct,syncard)
		-- 检查当前同调素材组合是否满足额外卡组怪兽出场所需的空位数量。
		and Duel.GetLocationCountFromEx(tp,tp,g,syncard)>0
		and g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)<=1
		-- 检查当前同调素材组合是否满足必须作为同调素材的条件。
		and aux.MustMaterialCheck(g,tp,EFFECT_MUST_BE_SMATERIAL)
end
-- 判断该卡是否为通常召唤 summoned。
function c3096468.syncon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 生成可用于同调召唤的素材组合，包括主怪兽和手牌中的怪兽。
function c3096468.syntg(e,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local tp=syncard:GetControler()
	local lv=syncard:GetLevel()
	if lv<=c:GetLevel() then return false end
	local g=Group.FromCards(c)
	-- 获取场上满足同调条件的怪兽作为同调素材。
	local mg=Duel.GetSynchroMaterial(tp):Filter(c3096468.synfilter,c,syncard,c,f)
	-- 获取手牌中满足同调条件的怪兽作为同调素材。
	local exg=Duel.GetMatchingGroup(c3096468.synfilter,tp,LOCATION_HAND,0,c,syncard,c,f)
	mg:Merge(exg)
	return mg:IsExists(c3096468.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc)
end
-- 执行同调召唤操作，选择同调素材并设置最终的同调素材组。
function c3096468.synop(e,tp,eg,ep,ev,re,r,rp,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local lv=syncard:GetLevel()
	local g=Group.FromCards(c)
	-- 获取场上满足同调条件的怪兽作为同调素材。
	local mg=Duel.GetSynchroMaterial(tp):Filter(c3096468.synfilter,c,syncard,c,f)
	-- 获取手牌中满足同调条件的怪兽作为同调素材。
	local exg=Duel.GetMatchingGroup(c3096468.synfilter,tp,LOCATION_HAND,0,c,syncard,c,f)
	mg:Merge(exg)
	for i=1,maxc do
		local cg=mg:Filter(c3096468.syncheck,g,g,mg,tp,lv,syncard,minc,maxc)
		if cg:GetCount()==0 then break end
		local minct=1
		if c3096468.syngoal(g,tp,lv,syncard,minc,i) then
			minct=0
		end
		-- 提示玩家选择作为同调素材的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
		local sg=cg:Select(tp,minct,1,nil)
		if sg:GetCount()==0 then break end
		g:Merge(sg)
	end
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
		-- 遍历同调素材组中的每张卡。
		for tc in aux.Next(g) do
			-- 为手牌中的同调素材设置效果，使其在被除外时直接除外而非进入墓地。
			local e1=Effect.CreateEffect(c)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			tc:RegisterEffect(e1,true)
		end
	end
	-- 设置最终的同调素材组。
	Duel.SetSynchroMaterial(g)
end
-- 限制非不死族怪兽不能特殊召唤。
function c3096468.splimit(e,c)
	return not c:IsRace(RACE_ZOMBIE)
end
