--オルターガイスト・キードゥルガー
-- 效果：
-- 「幻变骚灵」怪兽2只
-- ①：这张卡以外的自己的「幻变骚灵」怪兽给与对方战斗伤害时，以对方墓地1只怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。这个效果特殊召唤的怪兽不在这张卡攻击宣言过的回合不能攻击。
-- ②：这张卡被战斗破坏的场合，以自己墓地1张「幻变骚灵」卡为对象才能发动。那张卡加入手卡。
function c76685519.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤的手续，需要「幻变骚灵」怪兽2只作为素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x103),2,2)
	-- ①：这张卡以外的自己的「幻变骚灵」怪兽给与对方战斗伤害时，以对方墓地1只怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。这个效果特殊召唤的怪兽不在这张卡攻击宣言过的回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76685519,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c76685519.spcon)
	e1:SetTarget(c76685519.sptg)
	e1:SetOperation(c76685519.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗破坏的场合，以自己墓地1张「幻变骚灵」卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76685519,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetTarget(c76685519.thtg)
	e2:SetOperation(c76685519.thop)
	c:RegisterEffect(e2)
end
-- 判定是否满足“这张卡以外的自己的「幻变骚灵」怪兽给与对方战斗伤害时”的发动条件
function c76685519.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep~=tp and tc:IsControler(tp) and tc:IsSetCard(0x103) and tc~=e:GetHandler()
end
-- 过滤对方墓地中可以表侧表示特殊召唤到这张卡所连接区的怪兽
function c76685519.spfilter(c,e,tp,zone)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果①的靶向选择与发动准备阶段
function c76685519.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=e:GetHandler():GetLinkedZone(tp)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c76685519.spfilter(chkc,e,tp,zone) end
	-- 检查对方墓地中是否存在可以特殊召唤到这张卡所连接区的合法怪兽
	if chk==0 then return Duel.IsExistingTarget(c76685519.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,zone) end
	-- 在系统提示栏显示“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c76685519.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,zone)
	-- 设置连锁信息，表明该效果包含特殊召唤操作，并记录目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的实际处理函数（特殊召唤目标怪兽并施加攻击限制）
function c76685519.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	-- 获取在发动时选择的作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合条件且连接区仍有空位，则将其在连接区表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and zone&0x1f~=0 and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)~=0 then
		-- 这个效果特殊召唤的怪兽不在这张卡攻击宣言过的回合不能攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetCondition(c76685519.atkcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 判定这张卡（击键录杜尔迦）在本回合是否未进行过攻击宣言，作为不能攻击效果的启用条件
function c76685519.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetOwner():GetAttackAnnouncedCount()==0
end
-- 过滤自己墓地中可以加入手牌的「幻变骚灵」卡
function c76685519.thfilter(c)
	return c:IsSetCard(0x103) and c:IsAbleToHand()
end
-- 效果②的靶向选择与发动准备阶段
function c76685519.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c76685519.thfilter(chkc) end
	-- 检查自己墓地中是否存在可以加入手牌的「幻变骚灵」卡
	if chk==0 then return Duel.IsExistingTarget(c76685519.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 在系统提示栏显示“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张符合条件的「幻变骚灵」卡作为效果对象
	local sg=Duel.SelectTarget(tp,c76685519.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁信息，表明该效果包含加入手牌操作，并记录目标卡片
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end
-- 效果②的实际处理函数（将目标卡片加入手牌）
function c76685519.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	-- 确认目标卡片是否仍符合效果条件，并进行「王家之谷」的适用判定
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将目标卡片加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
