--ダイナレスラー・システゴ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。从卡组把1只「恐龙摔跤手」怪兽或者1张「世界恐龙摔跤」加入手卡。
-- ②：这张卡被送去墓地的回合的结束阶段，对方场上的怪兽数量比自己场上的怪兽多的场合，以「恐龙摔跤手·西斯特玛剑龙」以外的自己墓地1只「恐龙摔跤手」怪兽为对象才能发动。那只怪兽特殊召唤。
function c56980148.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合才能发动。从卡组把1只「恐龙摔跤手」怪兽或者1张「世界恐龙摔跤」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56980148,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,56980148)
	e1:SetTarget(c56980148.thtg)
	e1:SetOperation(c56980148.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的回合的结束阶段
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c56980148.regop)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的回合的结束阶段，对方场上的怪兽数量比自己场上的怪兽多的场合，以「恐龙摔跤手·西斯特玛剑龙」以外的自己墓地1只「恐龙摔跤手」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(56980148,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1,56980149)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(c56980148.spcon)
	e3:SetTarget(c56980148.sptg)
	e3:SetOperation(c56980148.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡组中「恐龙摔跤手」怪兽或「世界恐龙摔跤」且能加入手卡
function c56980148.thfilter(c)
	return ((c:IsSetCard(0x11a) and c:IsType(TYPE_MONSTER)) or c:IsCode(90173539)) and c:IsAbleToHand()
end
-- 效果①的发动准备与效果处理分类确定
function c56980148.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c56980148.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理中的操作信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组选择1张满足条件的卡加入手卡并给对方确认
function c56980148.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c56980148.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 在被送去墓地时，给自身注册一个持续到回合结束的标记，用于记录被送去墓地的回合
function c56980148.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(56980148,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果②的发动条件：本回合被送去墓地，且对方场上的怪兽数量比自己场上的怪兽多
function c56980148.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否在本回合被送去墓地，且自己场上的怪兽数量小于对方场上的怪兽数量
	return e:GetHandler():GetFlagEffect(56980148)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
end
-- 过滤条件：自己墓地中「恐龙摔跤手·西斯特玛剑龙」以外的「恐龙摔跤手」怪兽，且能特殊召唤
function c56980148.spfilter(c,e,tp)
	return c:IsSetCard(0x11a) and not c:IsCode(56980148) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查怪兽区域空位、选择墓地中的目标怪兽并设置操作信息
function c56980148.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c56980148.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的怪兽可以作为对象
		and Duel.IsExistingTarget(c56980148.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c56980148.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理中的操作信息为：特殊召唤选中的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理：将选中的对象怪兽特殊召唤
function c56980148.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选中的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
