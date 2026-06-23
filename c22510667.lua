--剛鬼ザ・ソリッド・オーガ
-- 效果：
-- 「刚鬼」怪兽2只以上
-- ①：只要这张卡所连接区有「刚鬼」怪兽存在，这张卡不会被战斗·效果破坏。
-- ②：1回合1次，以「刚鬼 硬铠食人魔」以外的自己的主要怪兽区域1只「刚鬼」怪兽为对象才能发动。那只自己怪兽的位置向作为这张卡所连接区的自己的主要怪兽区域移动。这个效果在对方回合也能发动。
function c22510667.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少2个属于「刚鬼」的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xfc),2)
	c:EnableReviveLimit()
	-- 只要这张卡所连接区有「刚鬼」怪兽存在，这张卡不会被战斗·效果破坏。
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
	-- 1回合1次，以「刚鬼 硬铠食人魔」以外的自己的主要怪兽区域1只「刚鬼」怪兽为对象才能发动。那只自己怪兽的位置向作为这张卡所连接区的自己的主要怪兽区域移动。这个效果在对方回合也能发动。
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
-- 过滤满足条件的「刚鬼」怪兽，即场上正面表示的「刚鬼」怪兽
function c22510667.lkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfc)
end
-- 判断当前连接区是否存在「刚鬼」怪兽，用于触发效果条件
function c22510667.indcon(e)
	return e:GetHandler():GetLinkedGroup():IsExists(c22510667.lkfilter,1,nil)
end
-- 过滤满足条件的「刚鬼」怪兽，即自己场上正面表示的「刚鬼」怪兽且不在额外怪兽区（序列小于5）且不是自身
function c22510667.seqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfc) and c:GetSequence()<5 and not c:IsCode(22510667)
end
-- 设置效果目标选择函数，用于选择满足条件的「刚鬼」怪兽作为移动对象
function c22510667.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c22510667.seqfilter(chkc) end
	if chk==0 then
		local zone=bit.band(e:GetHandler():GetLinkedZone(),0x1f)
		-- 判断场上是否存在满足条件的「刚鬼」怪兽作为目标
		return Duel.IsExistingTarget(c22510667.seqfilter,tp,LOCATION_MZONE,0,1,nil)
			-- 判断目标怪兽移动后是否还有足够的空位
			and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0,zone)>0
	end
	-- 提示玩家选择要移动位置的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(22510667,0))  --"请选择要移动位置的怪兽"
	-- 选择满足条件的「刚鬼」怪兽作为目标
	Duel.SelectTarget(tp,c22510667.seqfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 设置效果处理函数，执行怪兽位置移动操作
function c22510667.seqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	local zone=bit.band(e:GetHandler():GetLinkedZone(),0x1f)
	if not tc:IsRelateToEffect(e) or tc:IsControler(1-tp)
		-- 判断目标怪兽是否仍然有效且在己方控制下且有足够空位
		or Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0,zone)<=0 then return end
	-- 提示玩家选择要移动到的位置
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	local flag=bit.bxor(zone,0xff)
	-- 选择一个可用的空格作为目标位置
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,flag)
	local nseq=math.log(s,2)
	-- 将目标怪兽移动到指定位置
	Duel.MoveSequence(tc,nseq)
end
