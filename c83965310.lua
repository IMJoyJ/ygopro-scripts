--D-HERO Bloo-D
-- 效果：
-- 这张卡不能通常召唤。把自己场上3只怪兽解放的场合才能特殊召唤。
-- ①：只要这张卡在怪兽区域存在，对方场上的表侧表示怪兽的效果无效化。
-- ②：1回合1次，以对方场上1只怪兽为对象才能发动。那只对方怪兽当作装备魔法卡使用给这张卡装备（只有1只可以装备）。
-- ③：这张卡的攻击力上升这张卡的效果装备的怪兽的原本攻击力一半数值。
function c83965310.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制，使这张卡不能被通常的特殊召唤方式召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 把自己场上3只怪兽解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83965310,0))  --"把自己场上3只怪兽解放特殊召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c83965310.spcon)
	e2:SetTarget(c83965310.sptg)
	e2:SetOperation(c83965310.spop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以对方场上1只怪兽为对象才能发动。那只对方怪兽当作装备魔法卡使用给这张卡装备（只有1只可以装备）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(83965310,1))  --"把对方怪兽给这张卡装备"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c83965310.eqcon)
	e3:SetTarget(c83965310.eqtg)
	e3:SetOperation(c83965310.eqop)
	c:RegisterEffect(e3)
	-- ①：只要这张卡在怪兽区域存在，对方场上的表侧表示怪兽的效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e4)
end
-- 特殊召唤规则的条件检查函数：检查玩家场上是否有3只可解放的怪兽，且解放后有足够的怪兽区域
function c83965310.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家场上可用于特殊召唤解放的怪兽组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 检查是否存在3只怪兽，满足解放后主怪兽区有空位且可被正常解放的条件
	return rg:CheckSubGroup(aux.mzctcheckrel,3,3,tp,REASON_SPSUMMON)
end
-- 特殊召唤规则的选择目标函数：选择要解放的3只怪兽并保存在效果标签对象中
function c83965310.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上可用于特殊召唤解放的怪兽组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家选择3只满足解放后有空位且可解放条件的怪兽
	local sg=rg:SelectSubGroup(tp,aux.mzctcheckrel,true,3,3,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作函数：解放选中的怪兽
function c83965310.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选中的怪兽组
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤函数：检查卡片是否带有本卡效果装备的标记
function c83965310.cfilter(c)
	return c:GetFlagEffect(83965310)>0
end
-- 装备效果的发动条件：这张卡没有通过自身效果装备的怪兽（只能装备1只）
function c83965310.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local eqg=c:GetEquipGroup()
	return eqg==nil or not eqg:IsExists(c83965310.cfilter,1,nil)
end
-- 装备效果的靶向/合法性检查：确认魔法与陷阱区域有空位，并选择对方场上1只可转移控制权的怪兽作为对象
function c83965310.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToChangeControler() end
	-- 检查己方魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查对方场上是否存在可以改变控制权的怪兽
		and Duel.IsExistingTarget(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只可以改变控制权的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备限制函数：该装备卡只能装备于此卡
function c83965310.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 装备效果的执行操作：将目标怪兽作为装备卡装备给此卡，并使其攻击力上升该怪兽原本攻击力的一半
function c83965310.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local atk=math.ceil(tc:GetTextAttack()/2)
		if tc:IsFacedown() then atk=0 end
		if atk<0 then atk=0 end
		-- 将目标怪兽作为装备卡装备给此卡，若装备失败则结束处理
		if not Duel.Equip(tp,tc,c,false) then return end
		tc:RegisterFlagEffect(83965310,RESET_EVENT+RESETS_STANDARD,0,0)
		-- 那只对方怪兽当作装备魔法卡使用给这张卡装备（只有1只可以装备）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c83965310.eqlimit)
		tc:RegisterEffect(e1)
		if atk>0 then
			-- ③：这张卡的攻击力上升这张卡的效果装备的怪兽的原本攻击力一半数值。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(atk)
			tc:RegisterEffect(e2)
		end
	end
end
