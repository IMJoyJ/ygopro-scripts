--七星天流抜刀術－「破軍」
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。和那只怪兽是卡名不同并是种族相同的1只7星怪兽当作攻击力上升700的装备魔法卡使用从手卡·卡组给作为对象的怪兽装备。这个效果装备的卡在结束阶段回到手卡。
-- ②：这张卡在墓地存在的状态，等级·阶级是8以上的对方怪兽被战斗破坏时才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果：①的卡片发动效果与②的墓地诱发效果
function s.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。和那只怪兽是卡名不同并是种族相同的1只7星怪兽当作攻击力上升700的装备魔法卡使用从手卡·卡组给作为对象的怪兽装备。这个效果装备的卡在结束阶段回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，等级·阶级是8以上的对方怪兽被战斗破坏时才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.thcon2)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
end
-- 过滤函数：自己场上表侧表示的怪兽，且手卡·卡组存在可装备的满足条件的7星怪兽
function s.cfilter(c,tp)
	return c:IsFaceup()
		-- 检查手卡·卡组是否存在满足条件的7星怪兽
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,c:GetCode(),c:GetRace(),tp)
end
-- 过滤函数：手卡·卡组中卡名不同、种族相同、等级为7的怪兽，且可以作为装备卡使用
function s.eqfilter(c,code,race,tp)
	return not c:IsCode(code) and c:IsType(TYPE_MONSTER)
		and c:IsLevel(7) and c:IsRace(race)
		and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- ①的效果的发动准备与对象选择
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=0
	if not e:GetHandler():IsLocation(LOCATION_SZONE) then ct=1 end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc,tp) end
	-- 检查自己场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 检查魔法与陷阱区域是否有可用的空格
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>ct end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果的对象
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- ①的效果的处理：从手卡·卡组选择怪兽作为装备卡装备，并设置攻击力上升及结束阶段回手牌的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若魔法与陷阱区域没有空位，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从手卡·卡组选择1只满足条件的7星怪兽
		local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tc:GetCode(),tc:GetRace(),tp)
		local sc=g:GetFirst()
		if not sc then return end
		-- 将选择的怪兽作为装备卡装备给对象怪兽，若装备失败则流程结束
		if not Duel.Equip(tp,sc,tc) then return end
		-- 当作攻击力上升700的装备魔法卡使用从手卡·卡组给作为对象的怪兽装备
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		sc:RegisterEffect(e1)
		-- 当作攻击力上升700的装备魔法卡使用
		local e2=Effect.CreateEffect(sc)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(700)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e2)
		local fid=sc:GetFieldID()
		sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果装备的卡在结束阶段回到手卡。②：这张卡在墓地存在的状态，等级·阶级是8以上的对方怪兽被战斗破坏时才能发动。这张卡加入手卡。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetLabelObject(sc)
		e3:SetCondition(s.thcon1)
		e3:SetOperation(s.thop1)
		-- 注册在结束阶段将装备卡送回手牌的延迟触发效果
		Duel.RegisterEffect(e3,tp)
	end
end
-- 装备限制：只能装备给作为对象的怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 检查结束阶段时该装备卡是否仍带有正确的标记，若标记不符则重置该效果
function s.thcon1(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else
		return true
	end
end
-- 结束阶段将装备的卡送回持有者手卡
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 将作为装备卡的怪兽加入持有者的手卡
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end
-- 过滤被战斗破坏的对方场上的等级或阶级在8以上的怪兽
function s.thcfilter(c,tp)
	return (c:GetPreviousLevelOnField()>=8 or c:GetPreviousRankOnField()>=8) and c:IsPreviousControler(1-tp)
end
-- 检查是否有等级或阶级在8以上的对方怪兽被战斗破坏
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thcfilter,1,nil,tp)
end
-- ②的效果的发动准备与效果分类设置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果处理信息为：将墓地的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②的效果的处理：将墓地的这张卡加入手卡并给对方确认
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍存在于墓地，且不受王家长眠之谷的影响
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将墓地的这张卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的这张卡
		Duel.ConfirmCards(1-tp,c)
	end
end
