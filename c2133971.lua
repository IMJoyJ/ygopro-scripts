--ユニオン・コントローラー
-- 效果：
-- 机械族·光属性怪兽＋「Y-机敏龙头」或「Z-无穷履带」
-- 把自己场上的上记的卡除外的场合才能从额外卡组特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡从额外卡组特殊召唤的场合才能发动。效果文本有「同盟怪兽」记述的1张魔法·陷阱卡从卡组加入手卡。
-- ②：1回合1次，自己主要阶段才能发动。机械族·光属性的1只通常怪兽或同盟怪兽从手卡特殊召唤。
local s,id,o=GetID()
-- 初始化函数：为这张卡登记融合素材名与融合召唤手续、接触融合手续，设置苏生限制和特殊召唤条件，并注册①检索魔法·陷阱、②从手卡特召怪兽的两个效果。
function s.initial_effect(c)
	-- 为本卡登记融合素材名单：包含「Y-机敏龙头」和「Z-无穷履带」，使融合手续能识别这些素材。
	aux.AddMaterialCodeList(c,6355563,33744268)
	-- 添加融合召唤手续：以1只光属性·机械族怪兽和1只「Y-机敏龙头」或「Z-无穷履带」作为融合素材进行融合召唤。
	aux.AddFusionProcFun2(c,s.matfilter1,s.matfilter2,true)
	-- 添加接触融合手续：将自己场上符合条件的素材除外作为COST，从额外卡组特殊召唤这张卡。
	aux.AddContactFusionProcedure(c,s.matfilter3,LOCATION_ONFIELD,0,Duel.Remove,POS_FACEUP,REASON_COST)
	c:EnableReviveLimit()
	-- 把自己场上的上记的卡除外的场合才能从额外卡组特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡从额外卡组特殊召唤的场合才能发动。效果文本有「同盟怪兽」记述的1张魔法·陷阱卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。机械族·光属性的1只通常怪兽或同盟怪兽从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.has_text_type=TYPE_UNION
-- 特殊召唤条件判定：本卡不在额外卡组时才允许特殊召唤，即防止在额外卡组状态下被其他效果直接特殊召唤，必须通过正规融合/接触融合手续出场。
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 素材过滤1：要求怪兽为光属性·机械族。
function s.matfilter1(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
end
-- 素材过滤2：要求怪兽卡名为「Y-机敏龙头」或「Z-无穷履带」。
function s.matfilter2(c)
	return c:IsFusionCode(6355563,33744268)
end
-- 接触融合素材过滤：必须可作为COST除外，且是「Y-机敏龙头」/「Z-无穷履带」，或位于主要怪兽区的怪兽。
function s.matfilter3(c)
	return c:IsAbleToRemoveAsCost() and (c:IsFusionCode(6355563,33744268) or c:IsLocation(LOCATION_MZONE))
end
-- ①效果的发动条件：这张卡是从额外卡组特殊召唤成功的场合。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
-- 检索过滤函数：卡组中的魔法·陷阱卡，效果文本记述有「同盟怪兽」，并且能够加入手卡。
function s.filter(c)
	-- 过滤条件核心判定：是魔法·陷阱卡、效果文本含有「同盟怪兽」、且当前可以加入手卡。
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.IsTypeInText(c,TYPE_UNION) and c:IsAbleToHand()
end
-- ①效果的目标处理：发动前确认卡组存在符合条件的卡，发动时向对方提示效果描述，并设定检索1张卡加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检查：卡组中是否存在至少1张满足s.filter的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示我方发动了该效果，并显示效果描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 登记效果处理信息：本次效果会将1张卡从卡组加入手卡（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行①效果：从卡组选择1张符合条件的魔法·陷阱卡加入手卡，并向对手展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，让玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张满足s.filter的魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将所选卡片加入其持有者的手卡，处理原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片向对方玩家展示确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②特召对象过滤：光属性·机械族的通常怪兽或同盟怪兽，且能够被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_NORMAL+TYPE_UNION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动条件：我方场上有可用怪兽区，且手牌中存在符合条件的特召对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方怪兽区域空格数大于0。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手牌中存在至少1只满足s.spfilter的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向对方玩家提示我方发动了②效果，并显示效果描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 登记效果处理信息：本次效果会从手牌特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行②效果：从手牌选择1只符合条件的怪兽，以表侧表示特殊召唤到我方场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时确认我方场上仍有可用怪兽区，否则直接结束不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示，让玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手牌选择1只满足s.spfilter的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将所选怪兽以表侧表示特殊召唤到我方场上，并检查其召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
