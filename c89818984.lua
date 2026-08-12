--花札衛－柳に小野道風－
-- 效果：
-- 这张卡不能通常召唤。把「花札卫-柳间小野道风-」以外的自己场上1只11星「花札卫」怪兽解放的场合可以特殊召唤。
-- ①：这张卡特殊召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以把那只怪兽特殊召唤。不是的场合，那张卡送去墓地。
-- ②：把场上的这张卡作为同调素材的场合，可以把包含这张卡的全部同调素材怪兽当作2星怪兽使用。
function c89818984.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把「花札卫-柳间小野道风-」以外的自己场上1只11星「花札卫」怪兽解放的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c89818984.hspcon)
	e1:SetTarget(c89818984.hsptg)
	e1:SetOperation(c89818984.hspop)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以把那只怪兽特殊召唤。不是的场合，那张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89818984,0))  --"抽1张卡并给双方确认"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c89818984.target)
	e2:SetOperation(c89818984.operation)
	c:RegisterEffect(e2)
	-- ②：把场上的这张卡作为同调素材的场合，可以把包含这张卡的全部同调素材怪兽当作2星怪兽使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e3:SetTarget(c89818984.syntg)
	e3:SetValue(1)
	e3:SetOperation(c89818984.synop)
	c:RegisterEffect(e3)
	-- ②：把场上的这张卡作为同调素材的场合，可以把包含这张卡的全部同调素材怪兽当作2星怪兽使用。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(89818984)
	e4:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e4)
end
-- 过滤满足特殊召唤解放条件的怪兽（自己场上「花札卫-柳间小野道风-」以外的11星「花札卫」怪兽）
function c89818984.hspfilter(c,tp)
	return c:IsSetCard(0xe6) and c:IsLevel(11) and not c:IsCode(89818984)
		-- 检查解放该怪兽后是否有可用的怪兽区域，且该怪兽必须由自己控制或是表侧表示
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则的召唤条件函数
function c89818984.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只满足特殊召唤解放条件的怪兽
	return Duel.CheckReleaseGroupEx(tp,c89818984.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则的素材选择目标函数
function c89818984.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上满足特殊召唤解放条件的怪兽组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c89818984.hspfilter,nil,tp)
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的解放执行操作函数
function c89818984.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选定的怪兽以进行特殊召唤
	Duel.Release(g,REASON_SPSUMMON)
end
-- 效果①（抽卡并特殊召唤/送墓）的发动准备与目标确认函数
function c89818984.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的效果处理对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为自己从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果①（抽卡并特殊召唤/送墓）的效果处理函数
function c89818984.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡，若成功抽到卡则继续处理
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		-- 获取刚刚抽到的那张卡
		local tc=Duel.GetOperatedGroup():GetFirst()
		-- 将抽到的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,tc)
		-- 中断当前效果处理，使后续的特殊召唤或送去墓地不与抽卡同时处理
		Duel.BreakEffect()
		if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0xe6) then
			if tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 检查自己场上是否有可用的怪兽区域
				and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 询问玩家是否选择将该怪兽特殊召唤
				and Duel.SelectYesNo(tp,aux.Stringid(89818984,1)) then  --"是否特殊召唤？"
				-- 将抽到的「花札卫」怪兽以表侧表示特殊召唤到自己场上
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		else
			-- 将抽到的非「花札卫」怪兽送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
		-- 洗切手牌
		Duel.ShuffleHand(tp)
	end
end
-- 定义花札卫同调素材的替代等级（当作2星使用）
function c89818984.cardiansynlevel(c)
	return 2
end
-- 过滤可作为同调素材的怪兽（必须在场上表侧表示且可以作为该同调怪兽的素材）
function c89818984.synfilter(c,syncard,tuner,f)
	return c:IsFaceupEx() and c:IsCanBeSynchroMaterial(syncard,tuner) and (f==nil or f(c,syncard))
end
-- 递归检查当前选择的同调素材组合是否合法
function c89818984.syncheck(c,g,mg,tp,lv,syncard,minc,maxc)
	g:AddCard(c)
	local ct=g:GetCount()
	local res=c89818984.syngoal(g,tp,lv,syncard,minc,ct)
		or (ct<maxc and mg:IsExists(c89818984.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc))
	g:RemoveCard(c)
	return res
end
-- 检查当前素材组合是否满足同调召唤的等级和数量要求
function c89818984.syngoal(g,tp,lv,syncard,minc,ct)
	-- 检查素材数量是否达到下限，且将这些素材送墓后是否有足够的额外怪兽区域用于同调召唤
	return ct>=minc and Duel.GetLocationCountFromEx(tp,tp,g,syncard)>0
		and (g:CheckWithSumEqual(Card.GetSynchroLevel,lv,ct,ct,syncard)
			or g:CheckWithSumEqual(c89818984.cardiansynlevel,lv,ct,ct,syncard))
		-- 检查所选素材是否满足必须成为同调素材的限制效果
		and aux.MustMaterialCheck(g,tp,EFFECT_MUST_BE_SMATERIAL)
end
-- 自定义同调素材选择的目标确认函数
function c89818984.syntg(e,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local tp=syncard:GetControler()
	local lv=syncard:GetLevel()
	if lv<=c:GetLevel() and lv<=c89818984.cardiansynlevel(c) then return false end
	local g=Group.FromCards(c)
	-- 获取自己场上除这张卡以外所有可用的同调素材怪兽
	local mg=Duel.GetSynchroMaterial(tp):Filter(c89818984.synfilter,c,syncard,c,f)
	return mg:IsExists(c89818984.syncheck,1,g,g,mg,tp,lv,syncard,minc,maxc)
end
-- 自定义同调素材选择的执行操作函数
function c89818984.synop(e,tp,eg,ep,ev,re,r,rp,syncard,f,min,max)
	local minc=min+1
	local maxc=max+1
	local c=e:GetHandler()
	local lv=syncard:GetLevel()
	local g=Group.FromCards(c)
	-- 获取自己场上除这张卡以外所有可用的同调素材怪兽
	local mg=Duel.GetSynchroMaterial(tp):Filter(c89818984.synfilter,c,syncard,c,f)
	for i=1,maxc do
		local cg=mg:Filter(c89818984.syncheck,g,g,mg,tp,lv,syncard,minc,maxc)
		if cg:GetCount()==0 then break end
		local minct=1
		if c89818984.syngoal(g,tp,lv,syncard,minc,i) then
			minct=0
		end
		-- 提示玩家选择要作为同调素材的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
		local sg=cg:Select(tp,minct,1,nil)
		if sg:GetCount()==0 then break end
		g:Merge(sg)
	end
	-- 将选定的怪兽组设置为本次同调召唤的素材
	Duel.SetSynchroMaterial(g)
end
