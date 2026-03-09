--トランスコード・トーカー
-- 效果：
-- 效果怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡是互相连接状态的场合，这张卡以及这张卡所互相连接区的怪兽的攻击力上升500，对方不能把那些作为效果的对象。
-- ②：以除「转码语者」外的自己墓地1只连接3以下的电子界族连接怪兽为对象才能发动（这个效果发动的回合，自己不是电子界族怪兽不能特殊召唤）。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
function c46947713.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加连接召唤手续，要求使用至少2只效果怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	-- ①：这张卡是互相连接状态的场合，这张卡以及这张卡所互相连接区的怪兽的攻击力上升500，对方不能把那些作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCondition(c46947713.atkcon)
	e1:SetTarget(c46947713.atktg)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置效果使连接怪兽不能成为对方的效果对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：以除「转码语者」外的自己墓地1只连接3以下的电子界族连接怪兽为对象才能发动（这个效果发动的回合，自己不是电子界族怪兽不能特殊召唤）。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(46947713,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,46947713)
	e3:SetCost(c46947713.spcost)
	e3:SetTarget(c46947713.sptg)
	e3:SetOperation(c46947713.spop)
	c:RegisterEffect(e3)
	-- 设置一个计数器，用于记录玩家在该回合中进行的特殊召唤次数
	Duel.AddCustomActivityCounter(46947713,ACTIVITY_SPSUMMON,c46947713.counterfilter)
end
-- 计数器过滤函数，仅当特殊召唤的卡片为电子界族时计数器增加1
function c46947713.counterfilter(c)
	return c:IsRace(RACE_CYBERSE)
end
-- 发动效果时检查是否为该回合第一次使用②的效果，并设置不能特殊召唤非电子界族怪兽的效果
function c46947713.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断该回合是否已使用过②的效果（即计数器是否为0）
	if chk==0 then return Duel.GetCustomActivityCount(46947713,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建并注册一个使对方玩家在本回合不能特殊召唤非电子界族怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c46947713.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到指定玩家的场上
	Duel.RegisterEffect(e1,tp)
end
-- 限制非电子界族怪兽不能特殊召唤的过滤函数
function c46947713.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_CYBERSE)
end
-- 判断该卡是否处于互相连接状态
function c46947713.atkcon(e)
	return e:GetHandler():GetMutualLinkedGroupCount()>0
end
-- 设置效果目标为该卡及互相连接区的怪兽
function c46947713.atktg(e,c)
	local g=e:GetHandler():GetMutualLinkedGroup()
	return c==e:GetHandler() or g:IsContains(c)
end
-- 筛选满足条件的墓地怪兽：电子界族、连接值不超过3、类型为连接怪兽且不是转码语者
function c46947713.filter(c,e,tp,zone)
	return c:IsRace(RACE_CYBERSE) and c:IsLinkBelow(3) and c:IsType(TYPE_LINK) and not c:IsCode(46947713)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 设置特殊召唤效果的目标选择条件，确保能从墓地选择符合条件的怪兽
function c46947713.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c46947713.filter(chkc,e,tp,zone) end
	-- 判断场上是否有足够的位置进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否在墓地中存在满足条件的怪兽
		and Duel.IsExistingTarget(c46947713.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c46947713.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
	-- 设置连锁操作信息，表明将要特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，将选中的怪兽从墓地特殊召唤到指定区域
function c46947713.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if tc:IsRelateToEffect(e) and zone~=0 then
		-- 将目标怪兽特殊召唤到指定区域
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
