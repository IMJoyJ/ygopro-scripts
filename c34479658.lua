--ダーク・アリゲーター
-- 效果：
-- 这张卡可以把1只爬虫类族怪兽解放作上级召唤。
-- ①：这张卡上级召唤成功时才能发动。把最多有为这张卡的上级召唤而解放的爬虫类族怪兽数量的「短吻鳄衍生物」（爬虫类族·暗·1星·攻2000/守0）在自己场上特殊召唤。
-- ②：上级召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把「暗黑短吻鳄」以外的1只爬虫类族怪兽加入手卡。
function c34479658.initial_effect(c)
	-- 上级召唤时，将1只爬虫类族怪兽解放作上级召唤
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
	-- 上级召唤成功时才能发动。把最多有为这张卡的上级召唤而解放的爬虫类族怪兽数量的「短吻鳄衍生物」（爬虫类族·暗·1星·攻2000/守0）在自己场上特殊召唤
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
	-- 上级召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把「暗黑短吻鳄」以外的1只爬虫类族怪兽加入手卡
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c34479658.valcheck)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	-- 检索满足条件的卡片组
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
-- 过滤函数，返回以玩家来看的场上满足种族为爬虫类族的怪兽
function c34479658.otfilter(c,tp)
	return c:IsRace(RACE_REPTILE) and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断是否满足上级召唤条件，即等级不低于7且祭品数量为1
function c34479658.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上满足条件的卡片组
	local mg=Duel.GetMatchingGroup(c34479658.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判断是否满足上级召唤条件，即等级不低于7且祭品数量为1
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 选择用于上级召唤的祭品并释放
function c34479658.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上满足条件的卡片组
	local mg=Duel.GetMatchingGroup(c34479658.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 选择用于上级召唤的祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 以召唤和素材原因解放祭品
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 判断上级召唤成功且有祭品
function c34479658.tkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_ADVANCE) and c:GetMaterialCount()>0
end
-- 设置特殊召唤衍生物的效果目标
function c34479658.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local matc=e:GetLabel()
	-- 判断是否可以特殊召唤衍生物
	if chk==0 then return matc>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,34479659,0,TYPES_TOKEN_MONSTER,2000,0,1,RACE_REPTILE,ATTRIBUTE_DARK) end
	-- 设置操作信息，表示将特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，表示将特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 处理特殊召唤衍生物的效果
function c34479658.tkop(e,tp,eg,ep,ev,re,r,rp)
	local matc=e:GetLabel()
	-- 获取玩家场上可用的空位数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then matc=1 end
	if matc>ft then matc=ft end
	if matc<=0 then return end
	-- 判断是否可以特殊召唤衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,34479659,0,TYPES_TOKEN_MONSTER,2000,0,1,RACE_REPTILE,ATTRIBUTE_DARK) then return end
	local ctn=true
	while matc>0 and ctn do
		-- 创建衍生物
		local token=Duel.CreateToken(tp,34479659)
		-- 特殊召唤衍生物
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		matc=matc-1
		-- 询问是否继续特殊召唤衍生物
		if matc<=0 or not Duel.SelectYesNo(tp,aux.Stringid(34479658,2)) then ctn=false end  --"是否继续特殊召唤？"
	end
	-- 完成特殊召唤衍生物
	Duel.SpecialSummonComplete()
end
-- 统计上级召唤时所使用的爬虫类族祭品数量
function c34479658.valcheck(e,c)
	local g=c:GetMaterial():Filter(Card.IsRace,nil,RACE_REPTILE)
	e:GetLabelObject():SetLabel(g:GetCount())
end
-- 判断上级召唤的这张卡被战斗或对方效果破坏
function c34479658.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤函数，返回以玩家来看的卡组中满足种族为爬虫类族且可加入手牌的怪兽
function c34479658.thfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToHand() and not c:IsCode(34479658)
end
-- 设置检索效果的目标
function c34479658.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c34479658.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理从卡组检索怪兽的效果
function c34479658.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c34479658.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
