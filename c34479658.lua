--ダーク・アリゲーター
-- 效果：
-- 这张卡可以把1只爬虫类族怪兽解放作上级召唤。
-- ①：这张卡上级召唤成功时才能发动。把最多有为这张卡的上级召唤而解放的爬虫类族怪兽数量的「短吻鳄衍生物」（爬虫类族·暗·1星·攻2000/守0）在自己场上特殊召唤。
-- ②：上级召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把「暗黑短吻鳄」以外的1只爬虫类族怪兽加入手卡。
function c34479658.initial_effect(c)
	-- 这张卡可以把1只爬虫类族怪兽解放作上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34479658,0))  --"把1只爬虫类族怪兽解放作上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c34479658.otcon)
	e1:SetOperation(c34479658.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- ①：这张卡上级召唤成功时才能发动。把最多有为这张卡的上级召唤而解放的爬虫类族怪兽数量的「短吻鳄衍生物」（爬虫类族·暗·1星·攻2000/守0）在自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34479658,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c34479658.tkcon)
	e3:SetTarget(c34479658.tktg)
	e3:SetOperation(c34479658.tkop)
	c:RegisterEffect(e3)
	-- 最多有为这张卡的上级召唤而解放的爬虫类族怪兽数量
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c34479658.valcheck)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	-- ②：上级召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把「暗黑短吻鳄」以外的1只爬虫类族怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(c34479658.thcon)
	e5:SetTarget(c34479658.thtg)
	e5:SetOperation(c34479658.thop)
	c:RegisterEffect(e5)
end
-- 定义祭品过滤函数：筛选可作为上级召唤解放的爬虫类族怪兽，条件为爬虫类族且（由自己控制，或对方场上表侧表示）。
function c34479658.otfilter(c,tp)
	return c:IsRace(RACE_REPTILE) and (c:IsControler(tp) or c:IsFaceup())
end
-- 上级召唤规则效果的条件：判断这张卡能否以1只爬虫类族怪兽解放作上级召唤，要求这张卡等级7以上、所需解放数不超过1，且存在可用的爬虫类族祭品。
function c34479658.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取双方怪兽区中满足otfilter的爬虫类族怪兽集合，作为可供上级召唤解放的候选祭品。
	local mg=Duel.GetMatchingGroup(c34479658.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 返回是否满足条件：这张卡等级≥7，需要解放的怪兽数量为1，且场上有可用的爬虫类族祭品。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行上级召唤的解放手续：从候选祭品中选择1只爬虫类族怪兽，将其设为这张卡的素材并解放，完成上级召唤的代价。
function c34479658.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 再次获取当前可用的爬虫类族祭品集合，用于选择解放对象。
	local mg=Duel.GetMatchingGroup(c34479658.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家从候选祭品中选择1只爬虫类族怪兽作为上级召唤的祭品。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选择的祭品解放，原因记为召唤和作为素材（REASON_SUMMON+REASON_MATERIAL）。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- ①效果的发动条件：这张卡是上级召唤成功，且拥有上级召唤时使用的素材（解放过怪兽）。
function c34479658.tkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_ADVANCE) and c:GetMaterialCount()>0
end
-- ①效果的发动目标检查：读取记录的可召唤衍生物数量，确认数量大于0、自己怪兽区有空位，且当前玩家可以特殊召唤「短吻鳄衍生物」。
function c34479658.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local matc=e:GetLabel()
	-- 确认可特殊召唤的衍生物数量大于0，且自己怪兽区有空闲位置。
	if chk==0 then return matc>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认当前玩家能够特殊召唤「短吻鳄衍生物」（爬虫类族·暗·1星·攻2000/守0的衍生物）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,34479659,0,TYPES_TOKEN_MONSTER,2000,0,1,RACE_REPTILE,ATTRIBUTE_DARK) end
	-- 设置操作信息：本次效果将生成衍生物（CATEGORY_TOKEN），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本次效果将进行特殊召唤（CATEGORY_SPECIAL_SUMMON），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 实际处理①效果：根据记录的数量在自己场上特殊召唤「短吻鳄衍生物」，受可用空格和「青眼精灵龙」等限制，每召1只询问是否继续，最后完成特殊召唤。
function c34479658.tkop(e,tp,eg,ep,ev,re,r,rp)
	local matc=e:GetLabel()
	-- 获取自己主要怪兽区当前可用的空格数量，用于限制可召唤衍生物的数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then matc=1 end
	if matc>ft then matc=ft end
	if matc<=0 then return end
	-- 在实际特殊召唤前再次确认玩家能够特殊召唤「短吻鳄衍生物」，若不能则效果不处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,34479659,0,TYPES_TOKEN_MONSTER,2000,0,1,RACE_REPTILE,ATTRIBUTE_DARK) then return end
	local ctn=true
	while matc>0 and ctn do
		-- 生成1只「短吻鳄衍生物」卡（卡号34479659）。
		local token=Duel.CreateToken(tp,34479659)
		-- 将衍生物以表侧表示特殊召唤到自己怪兽区，作为连续特殊召唤的一步。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		matc=matc-1
		-- 如果已召唤数量达到上限，或玩家选择不再继续，则终止循环。
		if matc<=0 or not Duel.SelectYesNo(tp,aux.Stringid(34479658,2)) then ctn=false end  --"是否继续特殊召唤？"
	end
	-- 完成整个特殊召唤流程，正式结算所有衍生物的特殊召唤。
	Duel.SpecialSummonComplete()
end
-- 统计这张卡上级召唤时用作素材的爬虫类族怪兽数量，并保存到①效果e3的标签中，用于决定衍生物召唤数量。
function c34479658.valcheck(e,c)
	local g=c:GetMaterial():Filter(Card.IsRace,nil,RACE_REPTILE)
	e:GetLabelObject():SetLabel(g:GetCount())
end
-- ②效果的发动条件：这张卡以上级召唤出场后，被战斗破坏，或被对方的效果破坏（破坏前控制权属于自己），且破坏前在主要怪兽区。
function c34479658.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- ②效果的检索过滤条件：从卡组选择「暗黑短吻鳄」以外的爬虫类族怪兽，且该卡可以加入手卡。
function c34479658.thfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToHand() and not c:IsCode(34479658)
end
-- ②效果的发动目标检查：确认卡组中存在符合条件的爬虫类族怪兽，并设置从卡组加入手牌的操作信息。
function c34479658.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己卡组中存在至少1只满足检索条件的爬虫类族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c34479658.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将从卡组把1张卡加入手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理②效果：从卡组选择1只符合条件的爬虫类族怪兽加入手牌，并向对方展示。
function c34479658.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示“请选择要加入手牌的卡”，引导玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组中筛选并选择1张符合条件的爬虫类族怪兽。
	local g=Duel.SelectMatchingCard(tp,c34479658.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手牌（效果处理）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡，确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
