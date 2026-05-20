--ガガガ・ホープ・タクティクス
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己场上的原本属性是光属性的「霍普」超量怪兽不会被效果破坏，对方不能把那些作为效果的对象。
-- ②：宣言1～12的任意等级，以包含「我我我」怪兽的自己场上2只表侧表示怪兽为对象才能发动。那些怪兽的等级变成宣言的等级。
-- ③：原本属性是光属性的「霍普」超量怪兽由自己超量召唤的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（抗性）、②效果（修改等级）和③效果（破坏对方卡片）的注册。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的原本属性是光属性的「霍普」超量怪兽不会被效果破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.target)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置不能成为对方效果的对象（过滤函数，仅在对方发动效果时生效）。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ②：宣言1～12的任意等级，以包含「我我我」怪兽的自己场上2只表侧表示怪兽为对象才能发动。那些怪兽的等级变成宣言的等级。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"修改等级"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.lvtg)
	e4:SetOperation(s.lvop)
	c:RegisterEffect(e4)
	-- ③：原本属性是光属性的「霍普」超量怪兽由自己超量召唤的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))  --"破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_SZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,id+o)
	e5:SetCondition(s.descon)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
-- 过滤自己场上原本属性是光属性的「霍普」超量怪兽。
function s.target(e,c)
	return c:GetOriginalAttribute()&ATTRIBUTE_LIGHT~=0 and c:IsSetCard(0x7f) and c:IsType(TYPE_XYZ)
end
-- 过滤场上表侧表示、有等级且可以作为效果对象的怪兽。
function s.lvcfilter(c,e)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsCanBeEffectTarget(e)
end
-- 检查选择的2只怪兽中是否包含「我我我」怪兽，且它们的等级不全等于宣言的等级。
function s.fselect(g,lv)
	if lv and g:IsExists(Card.IsLevel,1,nil,lv) then return false end
	return g:IsExists(Card.IsSetCard,1,nil,0x54)
end
-- ②效果的发动准备，计算可宣言的等级，让玩家宣言等级，并选择包含「我我我」怪兽的2只表侧表示怪兽作为对象。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己场上所有满足条件的表侧表示怪兽。
	local rg=Duel.GetMatchingGroup(s.lvcfilter,tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return rg:CheckSubGroup(s.fselect,2,2) end
	local lvt={}
	local pc=1
	for i=1,12 do
		if rg:CheckSubGroup(s.fselect,2,2,i) then
			lvt[i]=nil
			lvt[pc]=i
			pc=pc+1
		end
	end
	lvt[pc]=nil
	-- 提示玩家选择要宣言的等级。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))  --"请选择要宣言的等级"
	-- 让玩家从可宣言的等级列表中宣言一个等级。
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	e:SetLabel(lv)
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=rg:SelectSubGroup(tp,s.fselect,false,2,2,lv)
	-- 将选择的怪兽组设置为效果的对象。
	Duel.SetTargetCard(sg)
end
-- ②效果的处理，将作为对象的怪兽的等级变成宣言的等级。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为对象的卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToChain,nil):Filter(Card.IsFaceup,nil)
	-- 遍历所有仍存在于场上且与连锁相关的对象怪兽。
	for tc in aux.Next(tg) do
		-- 那些怪兽的等级变成宣言的等级。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 过滤由自己超量召唤成功的原本属性是光属性的「霍普」超量怪兽。
function s.cfilter(c,tp)
	return c:IsFaceup() and c:GetOriginalAttribute()&ATTRIBUTE_LIGHT~=0 and c:IsSetCard(0x7f) and c:IsType(TYPE_XYZ)
		and c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- ③效果的发动条件判定，检查是否有原本属性是光属性的「霍普」超量怪兽由自己超量召唤成功。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ③效果的发动准备，确认对方场上是否存在可破坏的卡并将其作为对象，设置破坏操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象的卡片。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏操作的信息，包含目标卡片和数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ③效果的处理，将作为对象的对方场上的卡破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		-- 将目标卡片因效果破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
