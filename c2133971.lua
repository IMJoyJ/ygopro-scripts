--ユニオン・コントローラー
-- 效果：
-- 机械族·光属性怪兽＋「Y-机敏龙头」或「Z-无穷履带」
-- 把自己场上的上记的卡除外的场合才能从额外卡组特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡从额外卡组特殊召唤的场合才能发动。效果文本有「同盟怪兽」记述的1张魔法·陷阱卡从卡组加入手卡。
-- ②：1回合1次，自己主要阶段才能发动。机械族·光属性的1只通常怪兽或同盟怪兽从手卡特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数，设置融合召唤条件、接触融合、特殊召唤限制及两个效果
function s.initial_effect(c)
	-- 为该卡添加允许作为融合素材的卡牌代码（6355563和33744268）
	aux.AddMaterialCodeList(c,6355563,33744268)
	-- 设置融合召唤需要满足matfilter1和matfilter2条件的怪兽各1只作为素材
	aux.AddFusionProcFun2(c,s.matfilter1,s.matfilter2,true)
	-- 设置接触融合召唤的规则，需要将自己场上的符合条件的卡除外作为召唤代价
	aux.AddContactFusionProcedure(c,s.matfilter3,LOCATION_ONFIELD,0,Duel.Remove,POS_FACEUP,REASON_COST)
	c:EnableReviveLimit()
	-- 设置该卡不能从额外卡组以外的位置特殊召唤
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- 效果①：这张卡从额外卡组特殊召唤的场合才能发动。效果文本有「同盟怪兽」记述的1张魔法·陷阱卡从卡组加入手卡
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
	-- 效果②：1回合1次，自己主要阶段才能发动。机械族·光属性的1只通常怪兽或同盟怪兽从手卡特殊召唤
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
-- 限制该卡不能从额外卡组以外的位置特殊召唤
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 过滤函数：判断素材是否为光属性机械族怪兽
function s.matfilter1(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
end
-- 过滤函数：判断素材是否为「Y-机敏龙头」或「Z-无穷履带」
function s.matfilter2(c)
	return c:IsFusionCode(6355563,33744268)
end
-- 过滤函数：判断场上可作为接触融合素材的卡是否满足条件
function s.matfilter3(c)
	return c:IsAbleToRemoveAsCost() and (c:IsFusionCode(6355563,33744268) or c:IsLocation(LOCATION_MZONE))
end
-- 条件函数：判断该卡是否从额外卡组特殊召唤
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
-- 过滤函数：判断卡组中是否存在效果文本有「同盟怪兽」记述的魔法·陷阱卡
function s.filter(c)
	-- 判断卡是否为魔法·陷阱卡且其文本中记述了「同盟怪兽」
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.IsTypeInText(c,TYPE_UNION) and c:IsAbleToHand()
end
-- 效果①的发动时的处理函数，检查是否有满足条件的卡并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：卡组中是否存在满足条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方提示该效果被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：将1张魔法·陷阱卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的发动处理函数，选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：判断手牌中是否存在可特殊召唤的光属性机械族通常怪兽或同盟怪兽
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_NORMAL+TYPE_UNION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动时的处理函数，检查是否有满足条件的卡并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：手牌中是否存在满足条件的怪兽且场上存在召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足发动条件：手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向对方提示该效果被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：将1只怪兽从手牌特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的发动处理函数，选择并特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足发动条件：场上是否存在召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
