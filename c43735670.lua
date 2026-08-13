--海晶乙女ブルースラッグ
-- 效果：
-- 4星以下的「海晶少女」怪兽1只
-- 自己对「海晶少女 青高海牛」1回合只能有1次连接召唤。
-- ①：这张卡连接召唤成功的场合，以「海晶少女 青高海牛」以外的自己墓地1只「海晶少女」怪兽为对象才能发动。那只怪兽加入手卡。这个效果的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。
function c43735670.initial_effect(c)
	-- 为这张卡添加连接召唤手续：所需素材为1只等级4以下且可作为「海晶少女」连接素材的怪兽。
	aux.AddLinkProcedure(c,c43735670.mfilter,1,1)
	c:EnableReviveLimit()
	-- 自己对「海晶少女 青高海牛」1回合只能有1次连接召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c43735670.regcon)
	e1:SetOperation(c43735670.regop)
	c:RegisterEffect(e1)
	-- ①：这张卡连接召唤成功的场合，以「海晶少女 青高海牛」以外的自己墓地1只「海晶少女」怪兽为对象才能发动。那只怪兽加入手卡。这个效果的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43735670,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(c43735670.thcon)
	e2:SetTarget(c43735670.thtg)
	e2:SetOperation(c43735670.thop)
	c:RegisterEffect(e2)
end
-- 判定连接素材的条件：等级4以下，并且作为连接素材时视为名字含有「海晶少女」的怪兽。
function c43735670.mfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkSetCard(0x12b)
end
-- 该连续效果的发动条件：这张卡以连接召唤方式特殊召唤成功。
function c43735670.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 当连接召唤成功时，给当前玩家注册一个直到结束阶段有效的自肃效果：不能将「海晶少女 青高海牛」以连接召唤方式特殊召唤，从而实现对同名卡1回合只能连接召唤1次的限制。
function c43735670.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 自己对「海晶少女 青高海牛」1回合只能有1次连接召唤。①：这张卡连接召唤成功的场合，以「海晶少女 青高海牛」以外的自己墓地1只「海晶少女」怪兽为对象才能发动。那只怪兽加入手卡。这个效果的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c43735670.splimit)
	-- 将上述“不能以连接召唤方式特殊召唤「海晶少女 青高海牛」”的自肃效果注册到当前连锁，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定函数：当特殊召唤的怪兽是「海晶少女 青高海牛」（卡号43735670）且召唤方式为连接召唤时，禁止该特殊召唤。
function c43735670.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(43735670) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
-- 诱发效果的发动条件：这张卡以连接召唤方式特殊召唤成功。
function c43735670.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 选择墓地对象的条件：是「海晶少女」怪兽、是怪兽卡、不是「海晶少女 青高海牛」本身、且能够加入手卡。
function c43735670.thfilter(c)
	return c:IsSetCard(0x12b) and c:IsType(TYPE_MONSTER) and not c:IsCode(43735670) and c:IsAbleToHand()
end
-- 设定①效果的对象选择：从自己墓地选1只满足条件的「海晶少女」怪兽为对象，并设置操作信息为回手牌。
function c43735670.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c43735670.thfilter(chkc) end
	-- 效果发动时检查能否选到对象：己方墓地存在至少1只满足thfilter条件的「海晶少女」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c43735670.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择卡片的提示消息，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方墓地选择1只满足条件的「海晶少女」怪兽作为效果对象，并加入当前连锁的对象列表。
	local g=Duel.SelectTarget(tp,c43735670.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 向系统告知本次连锁将进行“加入手卡”的处理，对象为选中的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将对象卡加入手卡，并给自己附加直到结束阶段生效的自肃效果：不能特殊召唤非水属性怪兽。
function c43735670.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这次效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡以效果原因送回其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
	-- 这个效果的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c43735670.splimit2)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能特殊召唤非水属性怪兽”的自肃效果注册到当前连锁，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定函数：禁止特殊召唤不是水属性的怪兽。
function c43735670.splimit2(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
