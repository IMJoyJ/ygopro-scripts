--ヴァリアンツM－マーキス
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：场地区域有「群豪世界-百识公国」存在的场合或者自己场上有炎属性「群豪」怪兽存在的场合才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面翻开。可以从那之中选1张「群豪」卡加入手卡。剩余回到卡组。
-- ②：怪兽区域的这张卡向其他的怪兽区域移动的场合才能发动。掷1次骰子，2～5出现的场合，选自己的魔法与陷阱区域1张怪兽卡在那个正对面的自己的主要怪兽区域特殊召唤。
function c87897777.initial_effect(c)
	-- 注册卡片关联密码，表示本卡效果中记载了「群豪世界-百识公国」的卡名
	aux.AddCodeList(c,75952542)
	-- 启用灵摆怪兽的灵摆属性（注册灵摆召唤和灵摆卡的发动等基本规则）
	aux.EnablePendulumAttribute(c)
	-- ①：场地区域有「群豪世界-百识公国」存在的场合或者自己场上有炎属性「群豪」怪兽存在的场合才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,87897777)
	e1:SetCondition(c87897777.spcon)
	e1:SetTarget(c87897777.sptg)
	e1:SetOperation(c87897777.spop)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面翻开。可以从那之中选1张「群豪」卡加入手卡。剩余回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DICE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,87897778)
	e2:SetTarget(c87897777.dctg)
	e2:SetOperation(c87897777.dcop)
	c:RegisterEffect(e2)
	-- ②：怪兽区域的这张卡向其他的怪兽区域移动的场合才能发动。掷1次骰子，2～5出现的场合，选自己的魔法与陷阱区域1张怪兽卡在那个正对面的自己的主要怪兽区域特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DICE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_MOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,87897779)
	e3:SetCondition(c87897777.mvcon)
	e3:SetTarget(c87897777.mvtg)
	e3:SetOperation(c87897777.mvop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的炎属性「群豪」怪兽
function c87897777.cfilter(c)
	return c:IsSetCard(0x17d) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceup()
end
-- 灵摆效果发动的条件函数：检查场地区域是否有「群豪世界-百识公国」或自己场上是否有炎属性「群豪」怪兽
function c87897777.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场地区域是否存在「群豪世界-百识公国」，或者自己场上是否存在满足过滤条件的怪兽
	return Duel.IsEnvironment(75952542) or Duel.IsExistingMatchingCard(c87897777.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 灵摆效果发动的目标函数：检查自身是否能特殊召唤到正对面的主要怪兽区域，并设置特殊召唤的操作信息
function c87897777.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	-- 设置特殊召唤的操作信息，表示此效果会特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 灵摆效果运行函数：将这张卡特殊召唤到其正对面的主要怪兽区域
function c87897777.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到指定的怪兽区域（正对面的主要怪兽区域）
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- 怪兽效果①的目标函数：检查卡组是否有卡，并设置掷骰子的操作信息
function c87897777.dctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组的数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	-- 设置掷骰子的操作信息，表示此效果会掷1次骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 过滤条件：可以加入手卡的「群豪」卡
function c87897777.thfilter(c)
	return c:IsSetCard(0x17d) and c:IsAbleToHand()
end
-- 怪兽效果①的运行函数：掷1次骰子，翻开对应数量的卡，选1张「群豪」卡加入手卡，其余洗回卡组
function c87897777.dcop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己卡组没有卡，则不处理效果
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 让玩家掷1次骰子，并获取出现的数目
	local dc=Duel.TossDice(tp,1)
	-- 确认自己卡组最上方对应骰子数目的卡
	Duel.ConfirmDecktop(tp,dc)
	-- 获取自己卡组最上方对应骰子数目的卡片组
	local dg=Duel.GetDecktopGroup(tp,dc)
	local g=dg:Filter(c87897777.thfilter,nil)
	-- 如果翻开的卡中有「群豪」卡，询问玩家是否选择其中1张加入手卡
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(87897777,0)) then  --"是否选卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡因效果加入手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,sg)
	end
	-- 将自己卡组洗牌（剩余的卡回到卡组并洗牌）
	Duel.ShuffleDeck(tp)
end
-- 怪兽效果②的发动条件函数：检查这张卡是否在怪兽区域移动到其他的怪兽区域
function c87897777.mvcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=tp)
end
-- 过滤条件：自己魔法与陷阱区域中，可以特殊召唤到其正对面主要怪兽区域的表侧表示怪兽卡
function c87897777.spfilter(c,e,tp)
	local zone=1<<c:GetSequence()
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 怪兽效果②的目标函数：检查是否存在可特殊召唤的卡，并设置掷骰子和特殊召唤的操作信息
function c87897777.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔法与陷阱区域是否存在满足特殊召唤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c87897777.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 设置掷骰子的操作信息，表示此效果会掷1次骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	-- 设置特殊召唤的操作信息，表示此效果会从魔法与陷阱区域特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
end
-- 怪兽效果②的运行函数：掷1次骰子，若出现2～5，则选自己魔法与陷阱区域1张怪兽卡在那个正对面的主要怪兽区域特殊召唤
function c87897777.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家掷1次骰子，并获取出现的数目
	local dc=Duel.TossDice(tp,1)
	if dc<2 or dc>5 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己魔法与陷阱区域1张满足特殊召唤条件的怪兽卡
	local g=Duel.SelectMatchingCard(tp,c87897777.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽卡特殊召唤到其正对面的主要怪兽区域
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,1<<tc:GetSequence())
	end
end
