--ピュアリィ・リリィ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把速攻魔法卡以外的1张「纯爱妖精」卡加入手卡。
-- ②：以自己墓地1张「纯爱妖精」速攻魔法卡为对象才能发动。把有那个卡名记述的1只超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤，把作为对象的卡在那只超量怪兽下面重叠作为超量素材。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果：①召唤·特殊召唤成功时检索「纯爱妖精」卡，②以墓地速攻魔法为对象重叠超量召唤
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把速攻魔法卡以外的1张「纯爱妖精」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：以自己墓地1张「纯爱妖精」速攻魔法卡为对象才能发动。把有那个卡名记述的1只超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤，把作为对象的卡在那只超量怪兽下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 检索过滤条件：卡名含有「纯爱妖精」且不是速攻魔法的可以加入手牌的卡
function s.thfilter(c)
	return c:IsSetCard(0x18c) and c:IsAbleToHand() and not c:IsType(TYPE_QUICKPLAY)
end
-- ①效果的发动准备与效果分类设置（检索卡组）
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查卡组中是否存在满足检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果包含从卡组将1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- ①效果的处理：从卡组选择1张满足条件的卡加入手牌并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 额外卡组超量怪兽的过滤条件：文本中记述了指定卡名、可以超量召唤、是超量怪兽、能以自身为超量素材且额外卡组特召区域有空位
function s.sptgexfilter(c,e,tp,code)
	local sc=e:GetHandler()
	-- 检查额外卡组的怪兽文本中是否记述了作为对象的速攻魔法的卡名，且该怪兽可以进行超量召唤形式的特殊召唤
	return aux.IsCodeListed(c,code) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 检查该怪兽是否为超量怪兽、自身是否能作为其超量素材，以及额外卡组特殊召唤的可用位置是否足够
		and c:IsType(TYPE_XYZ) and sc:IsCanBeXyzMaterial(c) and Duel.GetLocationCountFromEx(tp,tp,sc,c)>0
end
-- 墓地速攻魔法的过滤条件：是「纯爱妖精」速攻魔法、可以作为超量素材叠放，且额外卡组存在满足特召条件的超量怪兽
function s.sptgfilter(c,e,tp)
	return c:IsType(TYPE_QUICKPLAY) and c:IsSetCard(0x18c) and c:IsCanOverlay()
		-- 检查额外卡组中是否存在记述了该速攻魔法卡名的、可特殊召唤的超量怪兽
		and Duel.IsExistingMatchingCard(s.sptgexfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetCode())
end
-- ②效果的发动准备与对象选择（选择墓地的「纯爱妖精」速攻魔法）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.sptgfilter(chkc,e,tp) end
	-- 在发动准备阶段，检查自身是否满足必须作为超量素材的规则限制
	if chk==0 then return aux.MustMaterialCheck(e:GetHandler(),tp,EFFECT_MUST_BE_XMATERIAL)
		-- 并检查自己墓地是否存在满足条件的「纯爱妖精」速攻魔法卡作为效果对象
		and Duel.IsExistingTarget(s.sptgfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择作为效果对象的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择墓地中1张满足条件的「纯爱妖精」速攻魔法卡作为对象
	local g=Duel.SelectTarget(tp,s.sptgfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表示该效果包含从额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置连锁信息，表示作为对象的墓地卡片将离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ②效果的处理：将自身作为素材，在上面重叠超量召唤额外卡组的超量怪兽，并将墓地的对象卡叠放为该超量怪兽的素材
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，再次检查自身是否满足必须作为超量素材的规则限制，不满足则不处理
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 获取作为效果对象的墓地速攻魔法卡
	local sc=Duel.GetFirstTarget()
	if not c:IsRelateToChain() or c:IsImmuneToEffect(e) or c:IsFacedown() or c:IsControler(1-tp) then return end
	if not sc:IsRelateToChain() then return end
	-- 提示玩家选择要特殊召唤的超量怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只记述了对象卡名的、满足特召条件的超量怪兽
	local sg=Duel.SelectMatchingCard(tp,s.sptgexfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,sc:GetCode())
	local tc=sg:GetFirst()
	if not tc then return end
	tc:SetMaterial(Group.FromCards(c))
	-- 将自身（场上的这张卡）重叠作为该超量怪兽的超量素材
	Duel.Overlay(tc,c)
	-- 将该超量怪兽以超量召唤的形式特殊召唤到场上
	Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
	-- 若作为对象的墓地卡片未受效果免疫且可以作为素材，则将其重叠作为该超量怪兽的超量素材
	if not sc:IsImmuneToEffect(e) and sc:IsCanOverlay() then Duel.Overlay(tc,sc) end
end
