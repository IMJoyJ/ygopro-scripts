--覇王門零
-- 效果：
-- ←0 【灵摆】 0→
-- ①：自己场上有「霸王龙 扎克」存在的场合，自己受到的全部伤害变成0。
-- ②：1回合1次，另一边的自己的灵摆区域有「霸王门 无限」存在的场合才能发动。自己的灵摆区域2张卡破坏，从卡组把1张「融合」魔法卡加入手卡。
-- 【怪兽效果】
-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示卡为对象才能发动。那张卡和这张卡破坏，把1只龙族融合怪兽或者龙族同调怪兽从额外卡组特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成0，效果无效化，不能作为同调·超量召唤的素材。
-- ②：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c96227613.initial_effect(c)
	-- 注册卡片脚本中记载了「霸王龙 扎克」（卡号13331639）的卡名
	aux.AddCodeList(c,13331639)
	-- 注册灵摆怪兽的灵摆召唤与灵摆卡发动等基本属性
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上有「霸王龙 扎克」存在的场合，自己受到的全部伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCondition(c96227613.ndcon)
	e1:SetValue(0)
	c:RegisterEffect(e1)
	local e0=e1:Clone()
	e0:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e0)
	-- ②：1回合1次，另一边的自己的灵摆区域有「霸王门 无限」存在的场合才能发动。自己的灵摆区域2张卡破坏，从卡组把1张「融合」魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96227613,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c96227613.thcon)
	e2:SetTarget(c96227613.thtg)
	e2:SetOperation(c96227613.thop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，以这张卡以外的自己场上1张表侧表示卡为对象才能发动。那张卡和这张卡破坏，把1只龙族融合怪兽或者龙族同调怪兽从额外卡组特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成0，效果无效化，不能作为同调·超量召唤的素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(96227613,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c96227613.sptg)
	e3:SetOperation(c96227613.spop)
	c:RegisterEffect(e3)
	-- ②：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(96227613,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c96227613.pencon)
	e4:SetTarget(c96227613.pentg)
	e4:SetOperation(c96227613.penop)
	c:RegisterEffect(e4)
end
-- 过滤条件：场上表侧表示的「霸王龙 扎克」
function c96227613.ndcfilter(c)
	return c:IsFaceup() and c:IsCode(13331639)
end
-- 灵摆效果①的发动条件：自己场上存在表侧表示的「霸王龙 扎克」
function c96227613.ndcon(e)
	-- 检查自己场上是否存在至少1张表侧表示的「霸王龙 扎克」
	return Duel.IsExistingMatchingCard(c96227613.ndcfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 灵摆效果②的发动条件：另一边的自己的灵摆区域有「霸王门 无限」存在
function c96227613.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查除自身外，自己的灵摆区域是否存在「霸王门 无限」（卡号22211622）
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_PZONE,0,1,e:GetHandler(),22211622)
end
-- 过滤条件：卡组中可以加入手牌的「融合」魔法卡
function c96227613.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x46) and c:IsAbleToHand()
end
-- 灵摆效果②的发动准备：检查卡组中是否有「融合」魔法卡，并设置破坏灵摆区2张卡和检索「融合」魔法卡的操作信息
function c96227613.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「融合」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c96227613.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 获取自己灵摆区域的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 设置连锁处理信息：破坏自己灵摆区域的2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置连锁处理信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果②的效果处理：破坏自己灵摆区域的2张卡，并从卡组把1张「融合」魔法卡加入手卡
function c96227613.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取自己灵摆区域的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if g:GetCount()<2 then return end
	-- 尝试破坏自己灵摆区域的2张卡，若成功破坏了2张则执行后续处理
	if Duel.Destroy(g,REASON_EFFECT)==2 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组中选择1张满足条件的「融合」魔法卡
		local sg=Duel.SelectMatchingCard(tp,c96227613.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 将选择的卡加入玩家手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
-- 过滤条件：自己场上表侧表示的卡，且该卡与本卡一同破坏时，能从额外卡组特殊召唤龙族融合或同调怪兽
function c96227613.desfilter(c,ec,e,tp)
	-- 检查该卡是否表侧表示，且在将该卡与本卡作为破坏对象时，额外卡组是否存在可特殊召唤的龙族融合或同调怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c96227613.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,Group.FromCards(c,ec))
end
-- 过滤条件：额外卡组中可以特殊召唤的龙族融合怪兽或龙族同调怪兽
function c96227613.spfilter(c,e,tp,mg)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查在将指定卡片（mg，即本卡和另一个破坏对象）送去墓地/离开场上后，额外卡组怪兽特殊召唤所需的额外怪兽区域或主要怪兽区域空位是否足够
		and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
-- 怪兽效果①的发动准备：选择自己场上1张表侧表示卡作为对象，并设置破坏与特殊召唤的操作信息
function c96227613.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c96227613.desfilter(chkc,c,e,tp) and chkc~=c end
	-- 检查自己场上是否存在除自身外、满足破坏并特召条件的表侧表示卡
	if chk==0 then return Duel.IsExistingTarget(c96227613.desfilter,tp,LOCATION_ONFIELD,0,1,c,c,e,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择1张除自身外的表侧表示卡作为效果对象
	local g=Duel.SelectTarget(tp,c96227613.desfilter,tp,LOCATION_ONFIELD,0,1,1,c,c,e,tp)
	g:AddCard(c)
	-- 设置连锁处理信息：破坏包含本卡在内的2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置连锁处理信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 怪兽效果①的效果处理：破坏对象卡和本卡，从额外卡组特殊召唤1只龙族融合或同调怪兽，并适用攻击力·守备力变成0、效果无效化、不能作为同调·超量素材的限制
function c96227613.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的另一张卡
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local dg=Group.FromCards(c,tc)
	-- 尝试破坏本卡和对象卡，若成功破坏了2张则执行后续处理
	if Duel.Destroy(dg,REASON_EFFECT)==2 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只满足条件的龙族融合或同调怪兽
		local g=Duel.SelectMatchingCard(tp,c96227613.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
		if g:GetCount()==0 then return end
		local sc=g:GetFirst()
		-- 尝试将选择的怪兽以表侧表示特殊召唤（分步处理）
		if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			-- 效果无效化
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1,true)
			-- 效果无效化
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e2,true)
			-- 这个效果特殊召唤的怪兽的攻击力·守备力变成0，不能作为同调·超量召唤的素材。②：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_SET_ATTACK_FINAL)
			e3:SetValue(0)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e3,true)
			local e4=e3:Clone()
			e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
			sc:RegisterEffect(e4,true)
			local e5=e3:Clone()
			e5:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			e5:SetValue(1)
			sc:RegisterEffect(e5,true)
			local e6=e5:Clone()
			e6:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
			sc:RegisterEffect(e6,true)
		end
		-- 完成特殊召唤的流程
		Duel.SpecialSummonComplete()
	end
end
-- 怪兽效果②的发动条件：原本在怪兽区域的这张卡在表侧表示状态下被破坏
function c96227613.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 怪兽效果②的发动准备：检查自己的灵摆区域是否有空位
function c96227613.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的左侧或右侧灵摆区域是否可用
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽效果②的效果处理：将这张卡放置在自己的灵摆区域
function c96227613.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示移动到自己的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
