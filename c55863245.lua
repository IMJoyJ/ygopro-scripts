--たつのこ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 同调召唤的这张卡为素材作同调召唤的场合，手卡1只怪兽也能作为同调素材。
-- ①：这张卡只要在怪兽区域存在，不受其他怪兽的效果影响。
function c55863245.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 同调召唤的这张卡为素材作同调召唤的场合，手卡1只怪兽也能作为同调素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c55863245.syncon)
	e1:SetTarget(c55863245.syntg)
	e1:SetValue(1)
	e1:SetOperation(c55863245.synop)
	c:RegisterEffect(e1)
	-- ①：这张卡只要在怪兽区域存在，不受其他怪兽的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(c55863245.efilter)
	c:RegisterEffect(e2)
	-- 同调召唤的这张卡为素材作同调召唤的场合，手卡1只怪兽也能作为同调素材。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e3:SetCondition(c55863245.syncon)
	e3:SetCode(EFFECT_HAND_SYNCHRO)
	e3:SetTargetRange(0,1)
	c:RegisterEffect(e3)
end
-- 过滤满足作为同调素材条件的卡片（包括场上和手牌）
function c55863245.synfilter(c,syncard,tuner,f)
	return c:IsFaceupEx() and c:IsCanBeSynchroMaterial(syncard,tuner) and (f==nil or f(c,syncard))
end
-- 递归检查当前选择的卡片组合是否能满足同调召唤的条件
function c55863245.syncheck(c,g,mg,tp,lv,syncard,minc,maxc)
	g:AddCard(c)
	local ct=g:GetCount()
	local res=c55863245.syngoal(g,tp,lv,syncard,minc,ct)
		or (ct<maxc and mg:IsExists(c55863245.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc))
	g:RemoveCard(c)
	return res
end
-- 检查当前选定的素材组合是否达成合法的同调召唤目标（等级匹配、额外区域空格、手牌素材不超过1张等）
function c55863245.syngoal(g,tp,lv,syncard,minc,ct)
	return ct>=minc
		and g:CheckWithSumEqual(Card.GetSynchroLevel,lv,ct,ct,syncard)
		-- 检查在这些素材离开场后，是否有足够的额外怪兽区域空格来特殊召唤该同调怪兽
		and Duel.GetLocationCountFromEx(tp,tp,g,syncard)>0
		and g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)<=1
		-- 检查选定的素材中是否包含了必须作为同调素材的卡
		and aux.MustMaterialCheck(g,tp,EFFECT_MUST_BE_SMATERIAL)
end
-- 检查自身是否为同调召唤登场（作为手牌同调素材效果的启用条件）
function c55863245.syncon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 自定义同调召唤的目标过滤与合法性检测，确认是否存在可行的同调素材组合
function c55863245.syntg(e,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local tp=syncard:GetControler()
	local lv=syncard:GetLevel()
	if lv<=c:GetLevel() then return false end
	local g=Group.FromCards(c)
	-- 获取场上可用的同调素材并过滤
	local mg=Duel.GetSynchroMaterial(tp):Filter(c55863245.synfilter,c,syncard,c,f)
	-- 获取手牌中可作为同调素材的怪兽
	local exg=Duel.GetMatchingGroup(c55863245.synfilter,tp,LOCATION_HAND,0,c,syncard,c,f)
	mg:Merge(exg)
	return mg:IsExists(c55863245.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc)
end
-- 执行自定义同调召唤的素材选择操作，并将其设置为同调素材
function c55863245.synop(e,tp,eg,ep,ev,re,r,rp,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local lv=syncard:GetLevel()
	local g=Group.FromCards(c)
	-- 获取场上可用的同调素材并过滤
	local mg=Duel.GetSynchroMaterial(tp):Filter(c55863245.synfilter,c,syncard,c,f)
	-- 获取手牌中可作为同调素材的怪兽
	local exg=Duel.GetMatchingGroup(c55863245.synfilter,tp,LOCATION_HAND,0,c,syncard,c,f)
	mg:Merge(exg)
	for i=1,maxc do
		local cg=mg:Filter(c55863245.syncheck,g,g,mg,tp,lv,syncard,minc,maxc)
		if cg:GetCount()==0 then break end
		local minct=1
		if c55863245.syngoal(g,tp,lv,syncard,minc,i) then
			minct=0
		end
		-- 提示玩家选择要作为同调素材的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
		local sg=cg:Select(tp,minct,1,nil)
		if sg:GetCount()==0 then break end
		g:Merge(sg)
	end
	-- 将选定的卡片组设置为本次同调召唤的素材
	Duel.SetSynchroMaterial(g)
end
-- 过滤不受影响的效果：必须是其他怪兽发动或产生的效果
function c55863245.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()
end
