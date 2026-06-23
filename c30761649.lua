--冀望郷－バリアン－
-- 效果：
-- 这个卡名在规则上也当作「异晶人的」卡使用。
-- ①：自己场上的「混沌超量」怪兽、「混沌No.」怪兽、「No.101」～「No.107」的「No.」怪兽不会成为对方的效果的对象，不会被对方的效果破坏。
-- ②：1回合1次，自己用「升阶魔法」魔法卡的效果对超量怪兽的特殊召唤成功的场合，以那1只超量怪兽和对方场上1只怪兽为对象才能发动。那只对方怪兽在那只超量怪兽下面重叠作为超量素材。
local s,id,o=GetID()
-- 注册场地魔法卡的发动效果，使该卡可以正常发动
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上的「混沌超量」怪兽、「混沌No.」怪兽、「No.101」～「No.107」的「No.」怪兽不会成为对方的效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.immtg)
	-- 设置效果值为过滤函数aux.tgoval，用于判断是否不会成为对方效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置效果值为过滤函数aux.indoval，用于判断是否不会被对方效果破坏
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- ②：1回合1次，自己用「升阶魔法」魔法卡的效果对超量怪兽的特殊召唤成功的场合，以那1只超量怪兽和对方场上1只怪兽为对象才能发动。那只对方怪兽在那只超量怪兽下面重叠作为超量素材
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))  --"对方怪兽作为超量素材"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.xyzcon)
	e4:SetTarget(s.xyztg)
	e4:SetOperation(s.xyzop)
	c:RegisterEffect(e4)
end
-- 判断目标怪兽是否为「异晶人」系列或「No.101」～「No.107」的「No.」怪兽
function s.immtg(e,c)
	if c:IsSetCard(0x1073,0x1048) then return true end
	-- 获取目标怪兽的No.编号
	local no=aux.GetXyzNumber(c)
	return c:IsSetCard(0x48) and no and no>=101 and no<=107
end
-- 判断目标怪兽是否为超量怪兽且由「升阶魔法」特殊召唤
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsType(TYPE_XYZ)
		and c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_SPELL~=0 and c:IsSpecialSummonSetCard(0x95)
end
-- 判断是否有满足条件的怪兽被特殊召唤成功
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 筛选满足条件的怪兽作为效果对象
function s.tgfilter1(c,g,tp)
	-- 判断目标怪兽是否为满足条件的怪兽且对方场上存在可作为超量素材的怪兽
	return g:IsContains(c) and Duel.IsExistingTarget(s.tgfilter2,tp,0,LOCATION_MZONE,1,c)
end
-- 判断目标怪兽是否可以作为超量素材
function s.tgfilter2(c)
	return c:IsCanOverlay()
end
-- 设置效果的处理流程，包括选择对象和确认目标
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=eg:Filter(s.cfilter,nil,tp)
	-- 检查是否满足发动条件，即对方场上存在可作为超量素材的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,g,tp) end
	local tg1
	if g:GetCount()==1 then
		tg1=g
		-- 设置目标卡片为已选择的怪兽
		Duel.SetTargetCard(g)
	else
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 选择满足条件的怪兽作为效果对象
		tg1=Duel.SelectTarget(tp,s.tgfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g,tp)
	end
	e:SetLabelObject(tg1:GetFirst())
	-- 提示玩家选择要作为超量素材的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择满足条件的怪兽作为超量素材
	Duel.SelectTarget(tp,s.tgfilter2,tp,0,LOCATION_MZONE,1,1,tg1)
end
-- 执行效果处理，将对方怪兽叠放至己方超量怪兽下方
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选择的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g~=2 then return end
	local tc1=e:GetLabelObject()
	local tc2=g:Filter(Card.IsControler,tc1,1-tp):GetFirst()
	if tc1:IsType(TYPE_XYZ) and tc1:IsFaceup() and not tc1:IsImmuneToEffect(e) and tc2 and not tc2:IsImmuneToEffect(e) and tc2:IsControler(1-tp) and tc2:IsType(TYPE_MONSTER) then
		local og=tc2:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将目标怪兽的叠放卡片送去墓地
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将目标怪兽叠放至己方超量怪兽下方
		Duel.Overlay(tc1,tc2)
	end
end
