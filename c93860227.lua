--優麗なる霊鏡姫
-- 效果：
-- 有怪兽卡装备的怪兽＋恶魔族怪兽卡
-- 把自己的手卡·场上的上记的卡送去墓地的场合才能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：「优丽的灵镜姬」在自己场上只能有1张表侧表示存在。
-- ②：怪兽为让卡的效果发动而从手卡送去墓地的场合，可以从以下效果选择1个发动。
-- ●那之内的1只当作攻击力上升500的装备魔法卡使用给这张卡装备。
-- ●自己抽1张。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果（场上唯一存在限制、召唤限制、融合素材、接触融合召唤手续、②效果）
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
	-- 设定融合素材：有怪兽卡装备的怪兽 ＋ 恶魔族怪兽卡
	aux.AddFusionProcFunFun(c,s.ffilter1,s.ffilter2,1,true)
	-- 设定接触融合召唤手续：将自己手卡·场上的上述素材送去墓地
	aux.AddContactFusionProcedure(c,Card.IsAbleToGraveAsCost,LOCATION_ONFIELD+LOCATION_HAND,0,Duel.SendtoGrave,REASON_COST)
	-- 把自己的手卡·场上的上记的卡送去墓地的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- ②：怪兽为让卡的效果发动而从手卡送去墓地的场合，可以从以下效果选择1个发动。这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"发动效果"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tscon)
	e2:SetTarget(s.tstg)
	e2:SetOperation(s.tsop)
	c:RegisterEffect(e2)
end
-- 过滤条件：原本卡片类型为怪兽卡的卡
function s.eqilter(c)
	return c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 融合素材1过滤条件：装备有原本是怪兽卡的卡的怪兽
function s.ffilter1(c,fc,sub,mg,sg)
	return c:GetEquipGroup():IsExists(s.eqilter,1,nil)
end
-- 融合素材2过滤条件：原本是怪兽卡且是恶魔族的卡
function s.ffilter2(c,fc,sub,mg,sg)
	return c:GetOriginalType()&TYPE_MONSTER~=0 and c:IsRace(RACE_FIEND)
end
-- 过滤条件：从手牌送去墓地的怪兽卡
function s.tgfilter(c)
	return c:IsPreviousLocation(LOCATION_HAND) and c:IsType(TYPE_MONSTER)
end
-- ②效果发动条件：有怪兽作为卡的效果发动的代价从手牌送去墓地
function s.tscon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return r&REASON_COST~=0 and eg:IsExists(s.tgfilter,1,nil)
end
-- 过滤条件：从手牌送去墓地、且可以作为装备卡装备的怪兽卡
function s.eqfilter(c)
	return c:IsPreviousLocation(LOCATION_HAND) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- ②效果的发动准备：检测并让玩家选择发动“装备”或“抽卡”效果，并设置对应的操作信息
function s.tstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足“装备”效果的分支条件（送去墓地的卡中有符合条件的怪兽，且自己魔陷区有空位）
	local b1=eg:IsExists(s.eqfilter,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	-- 检查是否满足“抽卡”效果的分支条件（玩家当前可以抽卡）
	local b2=Duel.IsPlayerCanDraw(tp,1)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 当两个分支都满足时，让玩家在“装备”和“抽卡”中选择一个
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))  --"装备/抽卡"
	elseif b1 then
		-- 当仅满足“装备”分支时，强制选择“装备”选项
		op=Duel.SelectOption(tp,aux.Stringid(id,1))  --"装备"
	else
		-- 当仅满足“抽卡”分支时，强制选择“抽卡”选项
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1  --"抽卡"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(0)
		-- 设置操作信息：涉及将墓地的卡移出墓地
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,0,0)
	else
		e:SetCategory(CATEGORY_DRAW)
		-- 设置操作信息：玩家抽1张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
-- ②效果的处理函数：根据玩家的选择，执行“装备”或“抽卡”的具体处理
function s.tsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==0 then
		-- 检查自身是否表侧表示存在、是否受效果影响，且自己魔陷区是否有空位
		if c:IsFaceup() and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			-- 提示玩家选择要装备的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 从送去墓地的卡中，筛选出1张不受王家长眠之谷影响且满足装备条件的卡
			local ec=eg:FilterSelect(tp,aux.NecroValleyFilter(s.eqfilter),1,1,nil):GetFirst()
			-- 若未选出卡或装备失败，则结束效果处理
			if ec==nil or not Duel.Equip(tp,ec,c) then return end
			-- ●那之内的1只当作……装备魔法卡使用给这张卡装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetLabelObject(c)
			e1:SetValue(s.eqlimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			ec:RegisterEffect(e1)
			-- 攻击力上升500
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(500)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			ec:RegisterEffect(e2)
		end
	else
		-- 执行效果处理：自己抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 装备限制：只能装备给这张卡
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
