--ポワソニエル・ド・ヌーベルズ
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己场上有仪式怪兽存在的场合，以场上1只怪兽为对象才能发动。这张卡特殊召唤。那之后，作为对象的怪兽的表示形式变更。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，可以从以下效果选择1个发动。
-- ●把1只1星仪式怪兽或者1张「食谱」卡从卡组加入手卡。
-- ●从自己墓地把「食谱」卡任意数量除外，把持有和那个数量相同等级的1只「新式魔厨」仪式怪兽从手卡特殊召唤。
-- ②：场上的这张卡被解放以表侧加入额外卡组的场合才能发动。这张卡在自己的灵摆区域放置。
local s,id,o=GetID()
-- 初始化卡片效果，注册灵摆和怪兽效果
function s.initial_effect(c)
	-- 为卡片添加灵摆属性
	aux.EnablePendulumAttribute(c)
	-- 注册灵摆效果①，条件为己方场上有仪式怪兽存在，对象为场上一只怪兽，效果为特殊召唤自身并改变对象表示形式
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 注册怪兽效果②，当此卡被解放加入额外卡组时发动，效果为放置于己方灵摆区域
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.pzcon)
	e2:SetTarget(s.pztg)
	e2:SetOperation(s.pzop)
	c:RegisterEffect(e2)
	-- 注册怪兽效果①，当此卡召唤或特殊召唤成功时发动，效果为选择以下效果之一：从卡组加入1只1星仪式怪兽或1张「食谱」卡到手牌；或从墓地除外任意数量「食谱」卡，特殊召唤1只等级与除外数量相同的「新式魔厨」仪式怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(s.target)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 定义过滤函数，用于判断场上是否有表侧表示的仪式怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL)
end
-- 灵摆效果①的发动条件，检查己方场上有无仪式怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上有无仪式怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置灵摆效果①的目标选择函数，检查是否有可改变表示形式的怪兽并满足特殊召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanChangePosition() end
	local c=e:GetHandler()
	-- 检查是否存在可改变表示形式的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查己方场上是否有空位且自身可特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，记录将要改变表示形式的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	-- 设置操作信息，记录将要特殊召唤的卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行灵摆效果①的操作函数，先特殊召唤自身再改变目标怪兽表示形式
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否能参与特殊召唤且成功特殊召唤
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)<1 then return end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 中断当前效果处理以避免错时点
		Duel.BreakEffect()
		-- 改变目标怪兽的表示形式为表侧守备、里侧守备、表侧攻击、表侧攻击（按顺序）
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- 定义怪兽效果②的发动条件，检查此卡是否因解放而从场上进入额外卡组且处于表侧表示状态
function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_RELEASE) and c:IsLocation(LOCATION_EXTRA)
		and c:IsFaceup()
end
-- 设置怪兽效果②的目标选择函数，检查己方灵摆区是否有空位
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方灵摆区是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 执行怪兽效果②的操作函数，将此卡移至己方灵摆区域
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否能参与移动并执行移动操作
	if c:IsRelateToEffect(e) then Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) end
end
-- 定义过滤函数，用于判断卡组中是否存在1星仪式怪兽或「食谱」卡
function s.filter(c)
	return (c:IsLevel(1) and c:IsType(TYPE_RITUAL) or c:IsSetCard(0x197)) and c:IsAbleToHand()
end
-- 定义过滤函数，用于判断墓地中是否存在「食谱」卡
function s.mfilter(c)
	return c:IsSetCard(0x197) and c:IsAbleToRemove()
end
-- 定义子函数，用于检查是否有满足条件的「新式魔厨」仪式怪兽可特殊召唤
function s.chk(g,e,tp)
	-- 检查是否存在满足条件的「新式魔厨」仪式怪兽可特殊召唤
	return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_HAND,0,1,nil,e,tp,#g)
end
-- 定义过滤函数，用于判断手牌中是否存在满足等级要求的「新式魔厨」仪式怪兽
function s.sfilter(c,e,tp,ct)
	return c:IsSetCard(0x196) and c:IsType(TYPE_RITUAL) and c:IsLevel(ct) and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
-- 设置怪兽效果①的目标选择函数，根据是否有符合条件的卡组卡片或墓地卡片决定发动选项
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合条件的1星仪式怪兽或「食谱」卡
	local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
	-- 获取己方墓地中所有「食谱」卡组成的集合
	local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查墓地中是否有满足条件的「食谱」卡可除外并召唤对应等级的「新式魔厨」仪式怪兽
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:CheckSubGroup(s.chk,1,99,e,tp)
	if chk==0 then return b1 or b2 end
	local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(id,3)},{b2,aux.Stringid(id,4)})  --"从卡组加入手卡/从手卡特殊召唤"
	if op==1 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		e:SetOperation(s.search)
		-- 设置操作信息，记录将要加入手牌的卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.psrsum)
		-- 设置操作信息，记录将要除外的卡
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
		-- 设置操作信息，记录将要特殊召唤的卡
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	end
end
-- 执行怪兽效果①的第一个选项操作，从卡组选择1张符合条件的卡加入手牌
function s.search(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡加入手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 确认对方看到所选卡
	Duel.ConfirmCards(1-tp,g)
end
-- 执行怪兽效果①的第二个选项操作，从墓地除外「食谱」卡并特殊召唤对应等级的「新式魔厨」仪式怪兽
function s.psrsum(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取己方墓地中所有「食谱」卡组成的集合
	local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local mg=g:SelectSubGroup(tp,s.chk,false,1,99,e,tp)
	if not mg then return end
	-- 将选中的卡除外
	local ct=Duel.Remove(mg,POS_FACEUP,REASON_EFFECT)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标卡
	local sg=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,ct)
	-- 将选中的卡特殊召唤
	Duel.SpecialSummon(sg,0,tp,tp,false,true,POS_FACEUP)
end
