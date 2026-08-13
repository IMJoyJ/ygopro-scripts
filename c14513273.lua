--覇王門の魔術師
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的②的灵摆效果1回合只能使用1次。
-- ①：自己场上的「霸王龙 扎克」不能用对方的效果除外。
-- ②：自己主要阶段才能发动。这张卡破坏，从手卡·卡组把「霸王门之魔术师」以外的1只「霸王门」灵摆怪兽在自己的灵摆区域放置。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：自己的灵摆区域有「霸王门之魔术师」以外的「霸王门」卡存在的场合才能发动。从手卡·额外卡组把「灵摆龙」「超量龙」「同调龙」「融合龙」怪兽之内1只送去墓地，这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。除魔法师族怪兽外的1张有「霸王龙 扎克」的卡名记述的卡从卡组加入手卡。
local s,id,o=GetID()
-- 初始化函数：为霸王门之魔术师登记自身记载的「霸王龙 扎克」卡名并赋予灵摆属性，然后依次注册4个效果：灵摆区的①（己方霸王龙扎克不被对方效果除外）、灵摆区的②（自毁并从手卡·卡组选霸王门灵摆怪放置到灵摆区）、手卡怪兽效果①（灵摆区有霸王门卡时送墓灵摆龙/超量龙/同调龙/融合龙之一并特召自身）、特殊召唤时的怪兽效果②（检索1张卡名记述有霸王龙扎克且非魔法师族的卡）。
function s.initial_effect(c)
	-- 在卡片c上登记“卡名记述了霸王龙扎克”这一信息，使后续可以检索/判断此类卡。
	aux.AddCodeList(c,13331639)
	-- 为这张卡赋予灵摆怪兽属性（支持灵摆召唤、灵摆卡发动等灵摆相关机制）。
	aux.EnablePendulumAttribute(c)
	-- 灵摆效果①：自己场上的「霸王龙 扎克」不能用对方的效果除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(s.rmlimit)
	c:RegisterEffect(e1)
	-- “这个卡名的②的灵摆效果1回合只能使用1次。”灵摆效果②：自己主要阶段才能发动。这张卡破坏，从手卡·卡组把「霸王门之魔术师」以外的1只「霸王门」灵摆怪兽在自己的灵摆区域放置。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.pentg)
	e2:SetOperation(s.penop)
	c:RegisterEffect(e2)
	-- 【怪兽效果】“这个卡名的①②的怪兽效果1回合各能使用1次。”怪兽效果①：自己的灵摆区域有「霸王门之魔术师」以外的「霸王门」卡存在的场合才能发动。从手卡·额外卡组把「灵摆龙」「超量龙」「同调龙」「融合龙」怪兽之内1只送去墓地，这张卡从手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"这张卡从手卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- “这个卡名的②的怪兽效果1回合只能使用1次。”怪兽效果②：这张卡特殊召唤的场合才能发动。除魔法师族怪兽外的1张有「霸王龙 扎克」的卡名记述的卡从卡组加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+o*2)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 该效果的排除限制判定：若卡片是自己场上的表侧表示且卡名为「霸王龙 扎克」（13331639），并且将要被对方的效果除外（不包含因效果改变去向的除外）时，禁止这次除外。
function s.rmlimit(e,c,rp,r,re)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp) and c:IsOnField() and c:IsCode(13331639) and c:IsFaceup()
		and r&REASON_EFFECT~=0 and r&REASON_REDIRECT==0 and rp==1-tp
end
-- 灵摆区放置的选卡过滤器：选择「霸王门」系列（0x10f8）且是灵摆怪兽、不是「霸王门之魔术师」自身、且没有被禁止的卡。
function s.penfilter(c)
	return c:IsSetCard(0x10f8) and c:IsType(TYPE_PENDULUM) and not c:IsCode(id) and not c:IsForbidden()
end
-- 发动条件判定：要求这张卡本身可以被效果破坏，并且从手卡·卡组中存在至少1张符合条件的「霸王门」灵摆怪兽。
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable()
		-- 追加条件：确认从手卡·卡组中能检索到至少1张满足条件的「霸王门」灵摆怪兽。
		and Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	-- 将本次连锁的操作信息设为“破坏”（对象为这张卡，数量1），以便其他卡（如星尘龙等）进行连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 灵摆②效果处理：先破坏这张卡；破坏成功时，从手卡·卡组中选择1张符合条件的「霸王门」灵摆怪兽，以表侧表示放置到自己的灵摆区域。
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行破坏这张卡，并确认破坏成功（实际破坏数量不为0）后才继续后续处理。
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
		-- 弹出选择提示，提示当前玩家“请选择要放置到场上的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从手卡·卡组中选出1张符合条件的「霸王门」灵摆怪兽。
		local g=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将选中的卡以表侧表示移动到自己的灵摆区域，并立即适用其效果。
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
-- 灵摆区域“霸王门”存在判定过滤器：卡属于「霸王门」系列且不是「霸王门之魔术师」自身。
function s.spfilter(c)
	return c:IsSetCard(0x10f8) and not c:IsCode(id)
end
-- 怪兽效果①的发动条件：自己的灵摆区域存在「霸王门之魔术师」以外的「霸王门」卡。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 该行具体判断：在己方灵摆区域检查是否存在至少1张满足「霸王门」且不是本卡的卡。
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_PZONE,0,1,nil)
end
-- 用于选择送去墓地的怪兽的过滤器：属于「灵摆龙」「超量龙」「同调龙」「融合龙」之一（字段0x10f2/0x2073/0x2017/0x1046）、是怪兽、且可以被送去墓地。
function s.spfilter2(c)
	return c:IsSetCard(0x10f2,0x2073,0x2017,0x1046) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 怪兽效果①的发动条件与合法性检查：自己主怪兽区有空位、这张卡可被特殊召唤、并且手卡·额外卡组存在符合条件的可供送墓的怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主怪兽区域是否有空位可以特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 并且检查手卡·额外卡组中是否存在至少1张符合条件的可供送去墓地的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：本次连锁包含“送去墓地”分类（预计从额外卡组处理1张），用于发动判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：本次连锁包含“特殊召唤”分类，并将要特殊召唤这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 怪兽效果①的处理：选1张符合条件的怪兽送去墓地；若成功送墓且这张卡仍与效果关联，则将这张卡从手卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示当前玩家“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡·额外卡组中选择1张符合条件的「灵摆龙」「超量龙」「同调龙」「融合龙」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil)
	local gc=g:GetFirst()
	-- 确认所选卡确实被效果成功送去了墓地，且当前位于墓地，才继续特殊召唤。
	if gc and Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE) then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			-- 将「霸王门之魔术师」从手卡以表侧表示特殊召唤到自己的怪兽区域。
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 检索过滤器：卡名记述有「霸王龙 扎克」、不是魔法师族、并且可以加入手卡。
function s.thfilter(c)
	-- 具体的检索条件为：该卡的文本中记载了13331639（霸王龙扎克），且不是魔法师族怪兽，且不被“不能加入手卡”效果限制。
	return aux.IsCodeListed(c,13331639) and not c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
-- 怪兽效果②的发动条件：卡组中存在满足条件的卡；并设置操作信息为从卡组加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张符合条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理为从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 怪兽效果②的处理：从卡组选1张符合条件的卡加入手卡，并向对方展示那张卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示当前玩家“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡用效果加入其持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
