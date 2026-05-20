--転生炎獣レイジング・フェニックス
-- 效果：
-- 炎属性效果怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用「转生炎兽 烈火凤凰」为素材作连接召唤的场合才能发动。从卡组把1张「转生炎兽」卡加入手卡。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的炎属性怪兽被战斗·效果破坏的场合，以那之内的1只为对象才能发动。这张卡特殊召唤，这张卡的攻击力上升作为对象的怪兽的攻击力数值。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含连接召唤手续、①效果（检索）、连接素材检测、②效果（墓地特召并加攻）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，需要2只以上满足过滤条件的怪兽作为素材
	aux.AddLinkProcedure(c,s.matfilter,2)
	-- ①：这张卡用「转生炎兽 烈火凤凰」为素材作连接召唤的场合才能发动。从卡组把1张「转生炎兽」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 这张卡用「转生炎兽 烈火凤凰」为素材作连接召唤的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的炎属性怪兽被战斗·效果破坏的场合，以那之内的1只为对象才能发动。这张卡特殊召唤，这张卡的攻击力上升作为对象的怪兽的攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤连接素材，必须是炎属性的效果怪兽
function s.matfilter(c)
	return c:IsLinkType(TYPE_EFFECT) and c:IsLinkAttribute(ATTRIBUTE_FIRE)
end
-- 检查连接素材中是否存在卡号为57134592（转生炎兽 烈火凤凰）的卡，并设置对应的Label值
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLinkCode,1,nil,57134592) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 检查①效果的发动条件，必须是连接召唤成功且使用了「转生炎兽 烈火凤凰」作为素材
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
-- 过滤卡组中可以加入手牌的「转生炎兽」卡片
function s.thfilter(c)
	return c:IsSetCard(0x119) and c:IsAbleToHand()
end
-- ①效果的发动准备，检查卡组中是否存在可检索的卡，并设置检索和加入手牌的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「转生炎兽」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果会从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理，从卡组选择1张「转生炎兽」卡加入手牌并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「转生炎兽」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤被破坏的怪兽，必须是自己场上原本表侧表示的、非衍生物的、炎属性且攻击力在1以上的怪兽，且因战斗或效果被破坏
function s.cfilter(c,tp)
	return not c:IsType(TYPE_TOKEN) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousAttributeOnField()&ATTRIBUTE_FIRE~=0
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsAttackAbove(1)
end
-- 过滤可以作为效果对象的被破坏怪兽，必须满足破坏条件且能成为效果对象
function s.tgfilter(c,e,tp)
	return s.cfilter(c,tp) and c:IsCanBeEffectTarget(e)
end
-- 检查②效果的发动条件，自己场上是否有表侧表示的炎属性怪兽被破坏，且被破坏的怪兽中不包含此卡自身
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- ②效果的发动准备，处理取对象逻辑，检查自身是否能特殊召唤以及怪兽区域是否有空位
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.tgfilter(chkc,e,tp) end
	local c=e:GetHandler()
	-- 检查被破坏的怪兽中是否存在可作为对象的目标，且自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return eg:IsExists(s.tgfilter,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=eg:FilterSelect(tp,s.tgfilter,1,1,nil,e,tp)
	-- 将选择的被破坏怪兽设置为当前连锁的效果对象
	Duel.SetTargetCard(g)
	-- 设置连锁的操作信息，表示该效果会将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果的处理，将此卡从墓地特殊召唤，并使此卡的攻击力上升作为对象的怪兽的攻击力数值
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍与效果相关，并将其以表侧表示特殊召唤到自己场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取当前连锁中作为效果对象的被破坏怪兽
		local tc=Duel.GetFirstTarget()
		if c:IsFaceup() and tc:IsRelateToEffect(e) then
			-- 这张卡的攻击力上升作为对象的怪兽的攻击力数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(tc:GetAttack())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
