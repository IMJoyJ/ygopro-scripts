--剛鬼ザ・ソリッド・オーガ
-- 效果：
-- 「刚鬼」怪兽2只以上
-- ①：只要这张卡所连接区有「刚鬼」怪兽存在，这张卡不会被战斗·效果破坏。
-- ②：1回合1次，以「刚鬼 硬铠食人魔」以外的自己的主要怪兽区域1只「刚鬼」怪兽为对象才能发动。那只自己怪兽的位置向作为这张卡所连接区的自己的主要怪兽区域移动。这个效果在对方回合也能发动。
function c22510667.initial_effect(c)
	-- 为这张卡添加连接召唤手续：以2只以上的「刚鬼」连接怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xfc),2)
	c:EnableReviveLimit()
	-- ①：只要这张卡所连接区有「刚鬼」怪兽存在，这张卡不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(c22510667.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以「刚鬼 硬铠食人魔」以外的自己的主要怪兽区域1只「刚鬼」怪兽为对象才能发动。那只自己怪兽的位置向作为这张卡所连接区的自己的主要怪兽区域移动。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c22510667.seqtg)
	e3:SetOperation(c22510667.seqop)
	c:RegisterEffect(e3)
end
-- 过滤条件：判定一张卡是否为表侧表示且属于「刚鬼」系列。
function c22510667.lkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfc)
end
-- ①效果的条件：检查这张卡的连接区是否存在至少1只表侧表示的「刚鬼」怪兽。
function c22510667.indcon(e)
	return e:GetHandler():GetLinkedGroup():IsExists(c22510667.lkfilter,1,nil)
end
-- ②效果的对象过滤：对象必须是表侧表示的「刚鬼」怪兽，位于自己的主要怪兽区（非额外怪兽区），且不能是「刚鬼 硬铠食人魔」自身。
function c22510667.seqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfc) and c:GetSequence()<5 and not c:IsCode(22510667)
end
-- ②效果的发动检测与取对象：在发动时确认存在符合条件的对象以及有可移动的空位，并让玩家选择要移动的「刚鬼」怪兽。
function c22510667.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c22510667.seqfilter(chkc) end
	if chk==0 then
		local zone=bit.band(e:GetHandler():GetLinkedZone(),0x1f)
		-- 检测自己主要怪兽区是否存在至少1张满足seqfilter条件的「刚鬼」怪兽作为对象。
		return Duel.IsExistingTarget(c22510667.seqfilter,tp,LOCATION_MZONE,0,1,nil)
			-- 检测这张卡所连接区的自己主要怪兽区是否有空位，确保对象能够移动过去。
			and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0,zone)>0
	end
	-- 提示玩家选择要移动位置的怪兽（HINT_SELECTMSG）。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(22510667,0))  --"请选择要移动位置的怪兽"
	-- 让玩家选择1只自己主要怪兽区符合条件的「刚鬼」怪兽并登记为效果对象。
	Duel.SelectTarget(tp,c22510667.seqfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理前的合法性检查：对象仍与效果关联、控制权未改变、且连接区主怪兽区仍有空位，否则中止处理。
function c22510667.seqop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的效果对象卡（要移动的「刚鬼」怪兽）。
	local tc=Duel.GetFirstTarget()
	local zone=bit.band(e:GetHandler():GetLinkedZone(),0x1f)
	if not tc:IsRelateToEffect(e) or tc:IsControler(1-tp)
		-- 如果没有可移动的空位（连接区对应的主怪兽区空格数<=0），则效果处理失败，直接中止。
		or Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0,zone)<=0 then return end
	-- 提示玩家选择要移动到的位置（HINTMSG_TOZONE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	local flag=bit.bxor(zone,0xff)
	-- 让玩家从可用的主怪兽区中选择1个格子作为移动目标，返回该格子的位置标记。
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,flag)
	local nseq=math.log(s,2)
	-- 将对象怪兽移动到玩家指定的格子，完成位置移动。
	Duel.MoveSequence(tc,nseq)
end
