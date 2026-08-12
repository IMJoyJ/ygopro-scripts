--EN－エンゲージ・ネオスペース
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。
-- ①：把1只「新空间侠」怪兽和1只「元素英雄」怪兽从手卡以及卡组各1只送去墓地才能发动。从卡组把1只「新空间侠」怪兽或者5星以上的「元素英雄」怪兽特殊召唤，从自己的卡组·墓地选1张「融合」加入手卡。这个效果特殊召唤的怪兽是「元素英雄 新宇侠」的场合，那个攻击力上升1000。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 记录该卡效果中记有「元素英雄 新宇侠」的卡名
	aux.AddCodeList(c,89943723)
	-- 记录该卡效果中记有「元素英雄」系列怪兽
	aux.AddSetNameMonsterList(c,0x3008)
	-- 这个卡名的卡在1回合只能发动1张
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 注册一个自定义活动计数器，用于检测玩家在额外卡组特殊召唤非融合怪兽的行为
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数：过滤非额外卡组特殊召唤，或者是融合怪兽的特殊召唤
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION)
end
-- Cost过滤条件：属于「新空间侠」或「元素英雄」系列的怪兽，且能送去墓地
function s.costfilter(c)
	return c:IsSetCard(0x1f,0x3008) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 检查选取的两张卡是否分别来自手卡和卡组，且一张是「新空间侠」另一张是「元素英雄」，并且卡组中存在可特殊召唤的怪兽
function s.fselect(g,e,tp)
	-- 检查两张卡是否分别来自不同的区域（手卡和卡组），且一张属于「新空间侠」系列，另一张属于「元素英雄」系列
	return g:GetClassCount(Card.GetLocation)==g:GetCount() and aux.gfcheck(g,Card.IsSetCard,0x1f,0x3008)
		-- 检查卡组中是否存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,g,e,tp)
end
-- 特殊召唤过滤条件：卡组中的「新空间侠」怪兽，或者5星以上的「元素英雄」怪兽
function s.spfilter(c,e,tp)
	return (c:IsSetCard(0x1f) or (c:IsLevelAbove(5) and c:IsSetCard(0x3008))) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动Cost处理函数：检查本回合是否未从额外卡组特殊召唤过非融合怪兽，并从手卡和卡组各将1张满足条件的怪兽送去墓地
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手卡和卡组中所有满足Cost过滤条件的怪兽
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	-- 检查本回合是否未从额外卡组特殊召唤过非融合怪兽
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
		and g:CheckSubGroup(s.fselect,2,2,e,tp) end
	-- 这张卡发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。①：把1只「新空间侠」怪兽和1只「元素英雄」怪兽从手卡以及卡组各1只送去墓地才能发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 给玩家注册“不能从额外卡组特殊召唤非融合怪兽”的限制效果
	Duel.RegisterEffect(e1,tp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,false,2,2,e,tp)
	-- 将选中的两张卡作为发动Cost送去墓地
	Duel.SendtoGrave(sg,REASON_COST)
end
-- 特殊召唤限制：不能从额外卡组特殊召唤非融合怪兽
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION)
end
-- 检索/回收过滤条件：卡名为「融合」的卡
function s.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果发动靶向/合法性检查函数：检查怪兽区域是否有空位，卡组是否有可特召的怪兽，且卡组或墓地是否有「融合」
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只可特殊召唤的「新空间侠」怪兽或5星以上的「元素英雄」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 检查卡组或墓地中是否存在至少1张「融合」
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置特殊召唤的操作信息（从卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 设置加入手卡的操作信息（从卡组或墓地将1张卡加入手卡）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理函数：特殊召唤怪兽，若是「元素英雄 新宇侠」则攻击力上升1000，然后将「融合」加入手卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的怪兽
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	-- 若成功选择怪兽，则将其以表侧表示特殊召唤
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
		if sc:IsCode(89943723) then
			-- 这个效果特殊召唤的怪兽是「元素英雄 新宇侠」的场合，那个攻击力上升1000。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
		end
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组或墓地选择1张「融合」（受王家之谷影响）
		local hg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		local tc=hg:GetFirst()
		if tc then
			-- 将选中的「融合」加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
