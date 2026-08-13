--R－ACEアビトレイター
-- 效果：
-- 炎属性怪兽2只以上
-- 自己对「救援ACE队 仲裁消防战车」1回合只能有1次特殊召唤，那个②的效果1回合可以使用最多2次。
-- ①：这张卡连接召唤的场合才能发动。从自己的卡组·墓地把1只「救援ACE队 消防栓」或1张「救援ACE队总部」加入手卡。
-- ②：自己把「救援ACE队」速攻魔法·通常陷阱卡发动的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册『救援ACE队总部』和『救援ACE队 消防栓』为关联卡名；设置“自己对『救援ACE队 仲裁消防战车』1回合只能有1次特殊召唤，那个②的效果1回合可以使用最多2次”的限制；设置炎属性怪兽2只以上的连接召唤手续；注册①检索效果（连接召唤成功时从卡组·墓地把1只『救援ACE队 消防栓』或1张『救援ACE队总部』加入手卡）和②破坏效果（自己发动『救援ACE队』速攻魔法·通常陷阱卡时，取对象破坏对方场上1张卡）。
function s.initial_effect(c)
	-- 将卡号63899465（救援ACE队总部）和37617348（救援ACE队 消防栓）记录为这张卡上记载的卡名，用于效果文本中提到的卡的检索与关联判定。
	aux.AddCodeList(c,63899465,37617348)
	c:SetSPSummonOnce(id)
	-- 设置连接召唤手续：需要2只以上炎属性怪兽作为连接素材，对应效果文本‘炎属性怪兽2只以上’。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_FIRE),2)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从自己的卡组·墓地把1只「救援ACE队 消防栓」或1张「救援ACE队总部」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己把「救援ACE队」速攻魔法·通常陷阱卡发动的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(2,id)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：只有在这张卡以连接召唤方式特殊召唤成功时才允许发动。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 定义①效果可检索的卡：卡名是「救援ACE队 消防栓」(37617348)或「救援ACE队总部」(63899465)，并且当前能够加入手卡。
function s.thfilter(c)
	return c:IsCode(63899465,37617348) and c:IsAbleToHand()
end
-- ①效果的发动判定与目标设定：在发动时检查自己的卡组·墓地有无满足条件的卡，并登记‘从卡组·墓地把卡加入手卡’的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动前检查：自己的卡组·墓地是否存在至少1张满足检索条件的卡，以此作为①效果能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 向系统登记本次处理会产生‘从卡组·墓地加入手卡’（CATEGORY_TOHAND）的操作信息，供星尘龙、王家长眠之谷等卡进行效果连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果处理：确认自己的卡组·墓地中满足条件的卡，选择1张加入手卡，并让对手确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出‘请选择要加入手牌的卡’的选择提示，供玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组·墓地中选出1张满足检索条件且不受‘王家长眠之谷’影响的卡；利用NecroValleyFilter来排除会被王家长眠之谷无效化的情况。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因（REASON_EFFECT）送去手卡（加入持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对方玩家确认，使双方都能确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件：自己发动了「救援ACE队」速攻魔法卡或通常陷阱卡（且该发动者为这张卡的控制者）时，可以发动此效果。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and (rc:GetType()==TYPE_TRAP or rc:GetType()&TYPE_QUICKPLAY==TYPE_QUICKPLAY)
		and rc:IsSetCard(0x18b)
end
-- ②效果的目标选择：以对方场上1张卡为对象；选择对象时利用flag标记保证同一连锁中本效果不会重复使用；随后登记‘破坏’操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 目标选择的合法性检查：对方场上存在可以作为对象的卡，且本效果在本连锁中尚未发动过（flag为0），满足这两个条件才能进入目标选择。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) and c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	-- 弹出‘请选择要破坏的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为本效果的对象，并将其登记为当前连锁的对象卡。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 向系统登记将对所选对象进行破坏（CATEGORY_DESTROY）的操作信息，用于连锁处理和效果记录。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：取得连锁开始时选择的对象卡，若该卡仍与连锁有关且仍在场上，则将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取回本连锁中作为对象的对方场上卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 以效果原因（REASON_EFFECT）将对象卡片破坏并送去墓地。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
