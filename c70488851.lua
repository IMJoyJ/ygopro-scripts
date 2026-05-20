--混絶獄神ヴィードリウム
-- 效果：
-- ←11 【灵摆】 11→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●这张卡破坏，从自己的手卡·墓地把1只「狱神」怪兽特殊召唤。
-- ●这张卡破坏。这个回合中，自己场上的原本等级是12星的「狱神」怪兽的攻击力上升5000。
-- 【怪兽效果】
-- 这张卡不能通常召唤。让融合·同调·超量怪兽各1只从自己的场上（表侧表示）·墓地回到额外卡组的场合才能从额外卡组·墓地特殊召唤。这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：这张卡表侧加入额外卡组的场合才能发动。从卡组把1张「狱神」卡加入手卡。
-- ②：这张卡特殊召唤的场合发动。双方墓地的卡全部里侧除外。
-- ③：场上的这张卡不受「狱神」怪兽以外的怪兽的效果影响。
local s,id,o=GetID()
-- 初始化效果注册函数，定义卡片的各项效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册灵摆怪兽的灵摆属性（灵摆召唤、灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- 这张卡不能通常召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：可以从以下效果选择1个发动。●这张卡破坏，从自己的手卡·墓地把1只「狱神」怪兽特殊召唤。●这张卡破坏。这个回合中，自己场上的原本等级是12星的「狱神」怪兽的攻击力上升5000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"选择效果"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 让融合·同调·超量怪兽各1只从自己的场上（表侧表示）·墓地回到额外卡组的场合才能从额外卡组·墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA+LOCATION_GRAVE)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- ①：这张卡表侧加入额外卡组的场合才能发动。从卡组把1张「狱神」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))  --"检索效果"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_DECK)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- ②：这张卡特殊召唤的场合发动。双方墓地的卡全部里侧除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,4))  --"除外效果"
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
	-- ③：场上的这张卡不受「狱神」怪兽以外的怪兽的效果影响。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(s.efilter)
	c:RegisterEffect(e5)
end
-- 过滤条件：手卡·墓地中可以特殊召唤的「狱神」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1ce) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 灵摆效果的发动准备（选择分支、设置破坏与特召/加攻的操作信息）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地是否存在可以特殊召唤的「狱神」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
	local b2=true
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家选择要发动的效果分支
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"特殊召唤"
			{b2,aux.Stringid(id,2),2})  --"上升攻击力"
	end
	e:SetLabel(op)
	-- 设置操作信息：破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
		end
		-- 设置操作信息：从手卡·墓地特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
		end
	end
end
-- 灵摆效果的处理（破坏自身，并根据选择的分支执行特殊召唤或增加攻击力）
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡在场上且成功被效果破坏
	if c:IsRelateToChain() and Duel.Destroy(c,REASON_EFFECT)>0 then
		-- 若选择了分支1（特殊召唤）且自己场上有空余的怪兽区域
		if e:GetLabel()==1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从手卡·墓地选择1只满足条件的「狱神」怪兽（受王家之谷影响）
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选择的怪兽表侧表示特殊召唤
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
	if e:GetLabel()==2 then
		-- 这个回合中，自己场上的原本等级是12星的「狱神」怪兽的攻击力上升5000。/让融合·同调·超量怪兽各1只从自己的场上（表侧表示）·墓地回到额外卡组的场合才能从额外卡组·墓地特殊召唤。/①：这张卡表侧加入额外卡组的场合才能发动。从卡组把1张「狱神」卡加入手卡。/②：这张卡特殊召唤的场合发动。双方墓地的卡全部里侧除外。/③：场上的这张卡不受「狱神」怪兽以外的怪兽的效果影响。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.atktg)
		e1:SetValue(5000)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册全局效果：使场上怪兽攻击力上升
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤条件：自己场上原本等级是12星的「狱神」怪兽
function s.atktg(e,c)
	return c:IsSetCard(0x1ce) and c:GetOriginalLevel()==12
end
-- 过滤条件：场上表侧表示或墓地中可以回到额外卡组的融合·同调·超量怪兽
function s.spfilter2(c)
	return c:IsFaceupEx() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) and c:IsAbleToExtraAsCost()
end
-- 检查选取的卡片组是否包含融合、同调、超量怪兽各1只，且满足特殊召唤的区域空格要求
function s.gcheck(g,ec,tp)
	-- 若从墓地特殊召唤，检查怪兽区域是否有足够空格（考虑素材离场）
	return (ec:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp,g)>0
		-- 若从额外卡组特殊召唤，检查额外怪兽区域或所连接的区域是否有足够空格（考虑素材离场）
		or ec:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,g,ec)>0)
		and g:FilterCount(Card.IsType,nil,TYPE_FUSION)==1
		and g:FilterCount(Card.IsType,nil,TYPE_SYNCHRO)==1
		and g:FilterCount(Card.IsType,nil,TYPE_XYZ)==1
end
-- 特殊召唤规则的条件检查（检查场上·墓地是否存在满足条件的融合·同调·超量怪兽各1只）
function s.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上（表侧表示）·墓地中所有可作为特殊召唤成本的融合·同调·超量怪兽
	local g=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,c)
	return g:CheckSubGroup(s.gcheck,3,3,c,tp)
end
-- 特殊召唤规则的素材选择（让玩家选择融合·同调·超量怪兽各1只作为特殊召唤的成本）
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上（表侧表示）·墓地中所有可作为特殊召唤成本的融合·同调·超量怪兽
	local g=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,c)
	-- 提示玩家选择要返回额外卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,true,3,3,c,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的具体执行（将选定的素材返回额外卡组，并特殊召唤自身）
function s.spop2(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 在场上对选定的素材卡片进行闪烁提示
	Duel.HintSelection(g)
	-- 将选定的素材卡片送回额外卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 怪兽效果①的发动条件：此卡表侧表示存在于额外卡组
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA)
		and c:IsFaceup()
end
-- 过滤条件：卡组中可以加入手卡的「狱神」卡片
function s.thfilter(c)
	return c:IsSetCard(0x1ce) and c:IsAbleToHand()
end
-- 怪兽效果①的发动准备（检查卡组中是否存在可检索的「狱神」卡并设置操作信息）
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡的「狱神」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 怪兽效果①的效果处理（从卡组将1张「狱神」卡加入手卡）
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张「狱神」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 怪兽效果②的发动准备（设置除外双方墓地所有卡片的操作信息）
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方墓地中所有可以里侧除外的卡片
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,tp,POS_FACEDOWN)
	-- 设置操作信息：将双方墓地的卡全部除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- 怪兽效果②的效果处理（将双方墓地的卡全部里侧除外）
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方墓地中所有可以里侧除外的卡片（受王家之谷影响）
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,tp,POS_FACEDOWN)
	-- 将获取的墓地卡片全部里侧除外
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
end
-- 过滤条件：不受「狱神」怪兽以外的怪兽的效果影响
function s.efilter(e,te)
	return not te:GetHandler():IsSetCard(0x1ce) and te:IsActiveType(TYPE_MONSTER)
end
