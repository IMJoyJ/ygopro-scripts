--時械巫女
-- 效果：
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：「时械神」怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
-- ③：把这张卡解放才能发动。从卡组把1只攻击力0的「时械神」怪兽加入手卡。
-- ④：把墓地的这张卡除外才能发动。从卡组把1只攻击力0的「时械神」怪兽无视召唤条件特殊召唤。这个效果发动的回合，自己不能用这个效果以外把怪兽特殊召唤。
function c27107590.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c27107590.sprcon)
	c:RegisterEffect(e1)
	-- ②：「时械神」怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e2:SetValue(c27107590.dtcon)
	c:RegisterEffect(e2)
	-- ③：把这张卡解放才能发动。从卡组把1只攻击力0的「时械神」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27107590,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c27107590.thcost)
	e3:SetTarget(c27107590.thtg)
	e3:SetOperation(c27107590.thop)
	c:RegisterEffect(e3)
	-- ④：把墓地的这张卡除外才能发动。从卡组把1只攻击力0的「时械神」怪兽无视召唤条件特殊召唤。这个效果发动的回合，自己不能用这个效果以外把怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(27107590,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCost(c27107590.spcost)
	e4:SetTarget(c27107590.sptg)
	e4:SetOperation(c27107590.spop)
	c:RegisterEffect(e4)
end
-- 效果①的特殊召唤手续条件：自己场上没有怪兽存在且有可用怪兽区域
function c27107590.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查主要怪兽区域是否有可用空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 判断被解放召唤的怪兽是否为「时械神」怪兽且满足解放适用条件
function c27107590.dtcon(e,c)
	local ec=e:GetHandler()
	return c:IsSetCard(0x4a) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
-- 效果③的发动代价：把自身解放
function c27107590.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身作为代价解放
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤卡组中攻击力为0且可加入手卡的「时械神」怪兽
function c27107590.thfilter(c)
	return c:IsSetCard(0x4a) and c:IsType(TYPE_MONSTER) and c:IsAttack(0) and c:IsAbleToHand()
end
-- 效果③的目标设置：确认卡组存在符合条件的怪兽并声明检索操作
function c27107590.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在攻击力为0的「时械神」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c27107590.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的操作处理：从卡组选择1只攻击力0的「时械神」怪兽加入手卡并向对方确认
function c27107590.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只攻击力为0的「时械神」怪兽
	local g=Duel.SelectMatchingCard(tp,c27107590.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果④的发动代价与誓约限制：本回合未进行过特殊召唤，把墓地的自身除外并施加本回合不能用该效果以外特殊召唤的誓约
function c27107590.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查本回合是否未进行过特殊召唤且自身可作为代价除外
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 and c:IsAbleToRemoveAsCost() end
	-- 将自身作为代价表侧表示除外
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	-- 这个效果发动的回合，自己不能用这个效果以外把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c27107590.splimit)
	e1:SetLabelObject(e)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册本回合不能用该效果以外特殊召唤怪兽的誓约限制
	Duel.RegisterEffect(e1,tp)
end
-- 过滤除本效果以外的其他特殊召唤效果
function c27107590.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return se~=e:GetLabelObject()
end
-- 过滤卡组中攻击力为0且可特殊召唤的「时械神」怪兽
function c27107590.spfilter(c,e,tp)
	return c:IsSetCard(0x4a) and c:IsType(TYPE_MONSTER) and c:IsAttack(0) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果④的目标设置：确认怪兽区域有空位且卡组存在符合条件的怪兽，并声明特殊召唤操作
function c27107590.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主要怪兽区域是否有可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在攻击力为0且可特殊召唤的「时械神」怪兽
		and Duel.IsExistingMatchingCard(c27107590.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果④的操作处理：从卡组将1只攻击力0的「时械神」怪兽无视召唤条件特殊召唤
function c27107590.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查主要怪兽区域是否有可用空格，无空格则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只攻击力为0的「时械神」怪兽
	local g=Duel.SelectMatchingCard(tp,c27107590.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽表侧表示无视召唤条件特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
