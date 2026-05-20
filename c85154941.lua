--デューク・デーモン
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的攻击力上升这张卡的等级×200。
-- ②：以自己场上1只表侧表示怪兽为对象才能发动。从卡组把「公爵恶魔」以外的1只「恶魔」怪兽送去墓地。作为对象的怪兽的等级上升送去墓地的怪兽的等级数值。
-- ③：这张卡在墓地存在的状态，自己的仪式怪兽被战斗破坏时才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含攻击力上升的永续效果、送墓并上升等级的起动效果，以及仪式怪兽被战破时自身特召的诱发效果。
function s.initial_effect(c)
	-- ①：这张卡的攻击力上升这张卡的等级×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只表侧表示怪兽为对象才能发动。从卡组把「公爵恶魔」以外的1只「恶魔」怪兽送去墓地。作为对象的怪兽的等级上升送去墓地的怪兽的等级数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的状态，自己的仪式怪兽被战斗破坏时才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 计算并返回攻击力上升的数值（自身等级×200）。
function s.atkval(e,c)
	return c:GetLevel()*200
end
-- 过滤条件：场上表侧表示且等级在1以上的怪兽。
function s.tgfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- 过滤条件：卡组中「公爵恶魔」以外的「恶魔」怪兽。
function s.filter(c)
	return c:IsSetCard(0x45) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() and not c:IsCode(id)
end
-- 效果②的发动准备，处理指向自己场上表侧表示怪兽的对象判定。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc)
		and chkc:IsControler(tp) end
	-- 检查自己场上是否存在可以作为对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查卡组中是否存在可以送去墓地的「公爵恶魔」以外的「恶魔」怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息：从卡组将1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②的操作处理：从卡组将1只「恶魔」怪兽送去墓地，并使对象怪兽的等级上升该数值。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只满足条件的「恶魔」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local gc=g:GetFirst()
		-- 将选择的怪兽送去墓地，并确认其已成功送去墓地。
		if Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE)
			and tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
			local lv=gc:GetLevel()
			-- 作为对象的怪兽的等级上升送去墓地的怪兽的等级数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(lv)
			tc:RegisterEffect(e1)
		end
	end
end
-- 过滤条件：原本在自己场上存在的仪式怪兽。
function s.cfilter(c,tp)
	local rm=TYPE_RITUAL|TYPE_MONSTER
	return c:GetPreviousTypeOnField()&rm==rm and c:IsPreviousControler(tp)
end
-- 效果③的发动条件：自己的仪式怪兽被战斗破坏，且被破坏的怪兽不包含墓地中的这张卡自身。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 效果③的发动准备：检查怪兽区域空位及自身是否能特殊召唤，并设置特召的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果③的操作处理：将墓地的这张卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍存在于墓地且不受「王家长眠之谷」的影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡以表侧表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
