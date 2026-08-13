--冀望郷－バリアン－
-- 效果：
-- 这个卡名在规则上也当作「异晶人的」卡使用。
-- ①：自己场上的「混沌超量」怪兽、「混沌No.」怪兽、「No.101」～「No.107」的「No.」怪兽不会成为对方的效果的对象，不会被对方的效果破坏。
-- ②：1回合1次，自己用「升阶魔法」魔法卡的效果对超量怪兽的特殊召唤成功的场合，以那1只超量怪兽和对方场上1只怪兽为对象才能发动。那只对方怪兽在那只超量怪兽下面重叠作为超量素材。
local s,id,o=GetID()
-- 初始化效果注册：先注册场地魔法本身的发动空效果；再注册①效果（自己场上符合条件的目标怪兽不会成为对方效果的对象、不会被对方效果破坏）；再注册②效果（自己用「升阶魔法」魔法卡效果对超量怪兽特殊召唤成功时，以那只超量怪兽和对方场上1只怪兽为对象发动，把对方怪兽叠放为超量素材）。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的「混沌超量」怪兽、「混沌No.」怪兽、「No.101」～「No.107」的「No.」怪兽不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.immtg)
	-- 设置“不能成为效果对象”的判定函数：只有对方发动的效果（发动玩家不是这张卡的控制者）才会被此免疫保护适用，即仅抵御对方的效果对象指定。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置“不会被效果破坏”的判定函数：只有对方发动的效果造成的破坏才会被此免疫保护适用，即仅抵御对方的效果破坏。
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- ②：1回合1次，自己用「升阶魔法」魔法卡的效果对超量怪兽的特殊召唤成功的场合，以那1只超量怪兽和对方场上1只怪兽为对象才能发动。那只对方怪兽在那只超量怪兽下面重叠作为超量素材。
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
-- ①效果的适用对象判定：若怪兽属于「混沌超量」或「混沌No.」字段则直接适用；否则获取其No.编号，若它是「No.」怪兽且编号在101～107之间也适用。
function s.immtg(e,c)
	if c:IsSetCard(0x1073,0x1048) then return true end
	-- 获取该卡的No.编号，用于判断是否属于「No.101」～「No.107」；非No.卡或编号不符时返回nil。
	local no=aux.GetXyzNumber(c)
	return c:IsSetCard(0x48) and no and no>=101 and no<=107
end
-- ②触发条件的过滤：被特殊召唤的怪兽须为表侧表示、是由我方玩家特殊召唤的超量怪兽，且其特殊召唤信息表明是通过魔法卡的效果进行特殊召唤，并且带有「升阶魔法」字段。
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsType(TYPE_XYZ)
		and c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_SPELL~=0 and c:IsSpecialSummonSetCard(0x95)
end
-- ②的发动条件：本次特殊召唤成功的事件组中，存在至少1只满足上述条件的超量怪兽，即我方用「升阶魔法」魔法卡效果特殊召唤了超量怪兽。
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 用于选择“那1只超量怪兽”的过滤：该怪兽必须是本次事件中符合条件的超量怪兽之一，并且对方场上有1只可作为超量素材的怪兽可以成为对象。
function s.tgfilter1(c,g,tp)
	-- 确认候选超量怪兽确实在本次特殊召唤成功的怪兽组中，且对方场上有可叠放的怪兽存在。
	return g:IsContains(c) and Duel.IsExistingTarget(s.tgfilter2,tp,0,LOCATION_MZONE,1,c)
end
-- 用于选择对方怪兽的过滤：该对方怪兽可以作为超量素材被叠放（满足可重叠的规则条件）。
function s.tgfilter2(c)
	return c:IsCanOverlay()
end
-- ②的取对象处理：先确定目标超量怪兽——若本次符合条件的超量怪兽只有1只则直接设为对象；若有复数只则由玩家选择其中1只；再选择对方场上1只可作为超量素材的怪兽作为对象，并把选中的超量怪兽保存到效果标签中供处理阶段使用。
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=eg:Filter(s.cfilter,nil,tp)
	-- 发动合法性检查：确认存在符合条件的超量怪兽可供选择，并且对方场上有1只可作为超量素材的怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,g,tp) end
	local tg1
	if g:GetCount()==1 then
		tg1=g
		-- 当本次符合条件的超量怪兽只有1只时，直接把这1只怪兽登记为效果对象，无需玩家选择。
		Duel.SetTargetCard(g)
	else
		-- 显示选择效果对象的提示消息，引导玩家选择要保护/关联的超量怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 让玩家从本次特殊召唤成功的符合条件的超量怪兽中选择1只，同时登记为效果的对象。
		tg1=Duel.SelectTarget(tp,s.tgfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g,tp)
	end
	e:SetLabelObject(tg1:GetFirst())
	-- 显示选择超量素材的提示消息，引导玩家选择要叠放到超量怪兽下方的对方怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择对方场上1只可作为超量素材的怪兽，同时登记为效果的对象。
	Duel.SelectTarget(tp,s.tgfilter2,tp,0,LOCATION_MZONE,1,1,tg1)
end
-- ②的发动处理：从连锁信息中取出仍与效果相关的对象卡；取出之前保存的超量怪兽和对方怪兽，确认它们仍满足条件后，先把对方怪兽原有的超量素材按规则送去墓地，再将对方怪兽重叠到那只超量怪兽下面作为超量素材。
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时登记的对象卡组，并过滤出仍与本次效果保持关联的对象（离场或联系重置的卡会被排除）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g~=2 then return end
	local tc1=e:GetLabelObject()
	local tc2=g:Filter(Card.IsControler,tc1,1-tp):GetFirst()
	if tc1:IsType(TYPE_XYZ) and tc1:IsFaceup() and not tc1:IsImmuneToEffect(e) and tc2 and not tc2:IsImmuneToEffect(e) and tc2:IsControler(1-tp) and tc2:IsType(TYPE_MONSTER) then
		local og=tc2:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将对方怪兽原本持有的超量素材按规则送去墓地。
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 把对方怪兽作为超量素材，叠放在那只超量怪兽下面。
		Duel.Overlay(tc1,tc2)
	end
end
